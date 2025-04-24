import SwiftUI
import AVKit
import FirebaseStorage
import FirebaseCore
import Firebase
import FirebaseAuth

// Singleton
class DownloadPlayViewModel: NSObject, ObservableObject {
    @Published var downloadProgress: Double = 0
    @Published var downloadedItems: [String] = []
    @Published var availableMusicItems: [String] = []
    @Published var player: AVPlayer?
    @Published var errorMessage: String?
    @Published var currentPlayingMusic: String? = nil
    
    static var dpvm: DownloadPlayViewModel?
    static func getDownloadPlay() -> DownloadPlayViewModel {
        if dpvm == nil {
            print("dpvm: Initialized")
            dpvm = DownloadPlayViewModel()
            return dpvm!
        }
        else {
            print("dpvm: I already exist.")
            return dpvm!
        }
    }
    
    private let storage = Storage.storage()
    
    override private init() {
        super.init()
        loadDownloadedMusic()
        fetchAvailableMusic()
    }
    
    private func loadDownloadedMusic() {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            DispatchQueue.main.async {
                self.downloadedItems = files.map { $0.lastPathComponent }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "加载已下载音乐失败: \(error.localizedDescription)"
            }
        }
    }
    
    private func fetchAvailableMusic() {
        let storageRef = storage.reference().child("music")
        
        storageRef.listAll { [weak self] result in
            switch result {
            case .success(let listResult):
                DispatchQueue.main.async {
                    self?.availableMusicItems = listResult.items.map { $0.name }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = "获取音乐列表失败: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func downloadFile(for musicName: String) {
        DispatchQueue.main.async {
            self.downloadProgress = 0
            self.errorMessage = nil
        }
        
        let musicRef = storage.reference().child("music/\(musicName)")
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsDirectory.appendingPathComponent(musicName)
        
        let downloadTask = musicRef.write(toFile: localURL)
        
        downloadTask.observe(.progress) { [weak self] snapshot in
            guard let self = self else { return }
            if let progress = snapshot.progress {
                let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                DispatchQueue.main.async {
                    self.downloadProgress = percentComplete
                }
            }
        }
        
        downloadTask.observe(.success) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.downloadedItems.append(musicName)
                self.downloadProgress = 1.0
            }
        }
        
        downloadTask.observe(.failure) { [weak self] snapshot in
            guard let self = self else { return }
            if let error = snapshot.error {
                DispatchQueue.main.async {
                    self.errorMessage = "下载失败: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func playMusic(_ musicName: String) {
        if let currentPlayer = player {
            currentPlayer.pause()
            player = nil
            currentPlayingMusic = nil
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let musicURL = documentsDirectory.appendingPathComponent(musicName)
        
        if FileManager.default.fileExists(atPath: musicURL.path) {
            DispatchQueue.main.async {
                self.player = AVPlayer(url: musicURL)
                self.currentPlayingMusic = musicName
                self.player?.play()
            }
        }
    }
    
    func stopPlaying() {
        player?.pause()
        player = nil
        currentPlayingMusic = nil
    }
    
    func deleteDownloadedMusic(_ musicName: String) {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let musicURL = documentsPath.appendingPathComponent(musicName)
        
        do {
            try fileManager.removeItem(at: musicURL)
            DispatchQueue.main.async {
                self.downloadedItems.removeAll { $0 == musicName }
                if self.currentPlayingMusic == musicName {
                    self.stopPlaying()
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "删除失败: \(error.localizedDescription)"
            }
        }
    }
}
extension DownloadPlayViewModel: URLSessionDownloadDelegate {
    // 使用 URLSession 下载并自动写入 Firestore 元数据
    func downloadWithMetadata(for musicName: String) {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "用户未登录"
            return
        }

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let storageRef = Storage.storage().reference().child("music/\(musicName)")

        storageRef.downloadURL { url, error in
            if let error = error {
                print("❌ 获取下载链接失败: \(error.localizedDescription)")
                self.errorMessage = "无法获取下载链接"
                return
            }

            guard let url = url else { return }
            let task = session.downloadTask(with: url)
            task.resume()
        }
    }

    // 下载完成后处理：保存本地 + 上传 Firestore + 播放器更新
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        do {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = downloadTask.originalRequest?.url?.lastPathComponent ?? "downloadedFile"
            let destinationURL = docs.appendingPathComponent(fileName)

            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: location, to: destinationURL)

            let userEmail = Auth.auth().currentUser?.email ?? ""
            let contentType = downloadTask.response?.mimeType ?? "audio/mpeg"
            let size = Int64((try? Data(contentsOf: destinationURL).count) ?? 0)

            let record = MusicRecord(
                userEmail: userEmail,
                musicName: fileName,
                filePath: destinationURL.path,
                downloadDate: Timestamp(date: Date()),
                size: size,
                contentType: contentType,
                isFavorite: false,
                localPath: destinationURL.path
            )

            FirebaseMusicManager.shared.storeUserMusicData(record: record) { success in
                DispatchQueue.main.async {
                    if success {
                        print("✅ Firestore 写入成功")
                    } else {
                        print("❌ Firestore 写入失败")
                        self.errorMessage = "上传音乐信息失败"
                    }
                }
            }

            DispatchQueue.main.async {
                self.downloadedItems.append(fileName)
                self.downloadProgress = 1.0
                self.player = AVPlayer(url: destinationURL)
            }

        } catch {
            print("⚠️ 保存文件失败: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "保存文件失败: \(error.localizedDescription)"
            }
        }
    }

    // 删除 Firestore 中的 user_musics 音乐记录
    func deleteMusicFromUserMusics(_ musicName: String) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        db.collection("user_musics")
            .whereField("userEmail", isEqualTo: user.email ?? "")
            .whereField("musicName", isEqualTo: musicName)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ 查找待删除音乐失败: \(error.localizedDescription)")
                    return
                }

                let batch = db.batch()
                snapshot?.documents.forEach { doc in
                    batch.deleteDocument(doc.reference)
                }

                batch.commit { error in
                    if let error = error {
                        print("❌ 删除失败: \(error.localizedDescription)")
                    } else {
                        print("✅ 删除成功: \(musicName)")
                    }
                }
            }
    }
    
    func deleteMusicEverywhere(_ musicName: String) {
        deleteDownloadedMusic(musicName)
        deleteMusicFromUserMusics(musicName)
    }

}
