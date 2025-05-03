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
    
    public func loadDownloadedMusic() {
        // 1) Clear and exit if not logged in
        guard let email = Auth.auth().currentUser?.email else {
            self.downloadedItems = []
            return
        }
        
        // 2) Query Firestore
        Firestore.firestore()
            .collection("user_musics")             // Your records collection
            .whereField("userEmail", isEqualTo: email)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to load downloaded music: \(error.localizedDescription)"
                    }
                    return
                }
                
                // 3) Extract musicName field and update UI
                let names = snapshot?.documents.compactMap { $0["musicName"] as? String } ?? []
                DispatchQueue.main.async {
                    self.downloadedItems = names
                    print("I loaded \(names)")
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
                    self?.errorMessage = "Failed to fetch music list: \(error.localizedDescription)"
                }
            }
        }
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
                    self.currentPlayingMusic = nil
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to delete: \(error.localizedDescription)"
            }
        }
    }
}

extension DownloadPlayViewModel: URLSessionDownloadDelegate {
    // Download using URLSession and automatically write Firestore metadata
    func downloadWithMetadata(for musicName: String) {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "User not logged in"
            return
        }

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let storageRef = Storage.storage().reference().child("music/\(musicName)")

        storageRef.downloadURL { url, error in
            if let error = error {
                print("❌ Failed to get download URL: \(error.localizedDescription)")
                self.errorMessage = "Unable to get download URL"
                return
            }

            guard let url = url else { return }
            let task = session.downloadTask(with: url)
            task.resume()
        }
    }

    // Handle download completion: save locally + upload to Firestore + update player
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
                        print("✅ Firestore write successful")
                    } else {
                        print("❌ Firestore write failed")
                        self.errorMessage = "Failed to upload music information"
                    }
                }
            }

            DispatchQueue.main.async {
                self.downloadedItems.append(fileName)
                self.downloadProgress = 1.0
            }

        } catch {
            print("⚠️ Failed to save file: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to save file: \(error.localizedDescription)"
            }
        }
    }

    // Delete music record from user_musics in Firestore
    func deleteMusicFromUserMusics(_ musicName: String) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        db.collection("user_musics")
            .whereField("userEmail", isEqualTo: user.email ?? "")
            .whereField("musicName", isEqualTo: musicName)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Failed to find music to delete: \(error.localizedDescription)")
                    return
                }

                let batch = db.batch()
                snapshot?.documents.forEach { doc in
                    batch.deleteDocument(doc.reference)
                }

                batch.commit { error in
                    if let error = error {
                        print("❌ Deletion failed: \(error.localizedDescription)")
                    } else {
                        print("✅ Deletion successful: \(musicName)")
                    }
                }
            }
    }
    
    func deleteMusicEverywhere(_ musicName: String) {
        deleteDownloadedMusic(musicName)
        deleteMusicFromUserMusics(musicName)
    }
}
