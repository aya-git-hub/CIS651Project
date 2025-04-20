import SwiftUI
import AVKit
import FirebaseStorage
import FirebaseCore

// MARK: - ViewModel
class DownloadPlayViewModel: NSObject, ObservableObject {
    @Published var downloadProgress: Double = 0
    @Published var downloadedItems: [String] = []
    @Published var availableMusicItems: [String] = []
    @Published var player: AVPlayer?
    @Published var errorMessage: String?
    @Published var currentPlayingMusic: String? = nil
    
    private let storage = Storage.storage()
    
    override init() {
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
