import Foundation
import AVKit

class DownloadPlayViewModel: NSObject, ObservableObject {
    @Published var downloadProgress: Double = 0            // 用于进度条
    @Published var downloadedItems: [String] = []          // 下载完成后追加
    @Published var player: AVPlayer?                       // 播放器实例
    @Published var musicNames: [String] = []
    @Published var errorMessage: String?                   // 下载错误时显示信息
    @Published var Musics: MusicsDao
    
    override init() {
        Musics = DaoGenerator().getMusicsDao()
        super.init()
        musicNames = Musics.getMusicsName()
        for name in musicNames {
            print(name)
        }
    }
    
    func insertMusicToTable(_ name: String, _ author: String) {
        Musics.insertMusics(name, author)
    }
    
    func getaMusicsList() -> [String] {
        musicNames = Musics.getMusicsName()
        for name in musicNames {
            print(name)
        }
        return musicNames
    }
    
    /// 根据所选音乐名称下载文件。如果该文件不存在，则在 error delegate 中捕获错误并更新 errorMessage。
    func downloadFile(for musicName: String) {
        // 构造 URL，注意：传入的 musicName 应包含扩展名（例如 "luther.m4p"）
        guard let url = URL(string: "http://127.0.0.1:5000/uploads/\(musicName)") else {
            print("URL 无效")
            self.errorMessage = "URL 无效"
            return
        }
        
        // 重置进度和错误信息
        DispatchQueue.main.async {
            self.downloadProgress = 0
            self.errorMessage = nil
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let task = session.downloadTask(with: url)
        task.resume()
    }
}

// MARK: - URLSessionDownloadDelegate
extension DownloadPlayViewModel: URLSessionDownloadDelegate {
    // 下载过程中更新进度
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.downloadProgress = progress
        }
    }
    
    // 下载完成后调用，将临时文件复制到 Documents 目录，并创建播放器
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        do {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            // 以下载任务请求中的最后部分作为文件名
            let fileName = downloadTask.originalRequest?.url?.lastPathComponent ?? "downloadedFile"
            let destinationURL = docs.appendingPathComponent(fileName)
            
            // 如果目标文件已存在，则先删除
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: location, to: destinationURL)
            
            DispatchQueue.main.async {
                self.downloadedItems.append(fileName)
                self.downloadProgress = 1.0
                self.player = AVPlayer(url: destinationURL)
            }
        } catch {
            print("移动文件出错: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "下载完成，但移动文件出错: \(error.localizedDescription)"
            }
        }
    }
    
    // 捕获下载错误，如 404 或其他网络错误
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if let error = error {
            print("下载过程中出现错误: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "下载失败: \(error.localizedDescription)"
            }
        }
    }
}
