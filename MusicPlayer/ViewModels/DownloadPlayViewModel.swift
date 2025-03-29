import Foundation
import AVKit

class DownloadPlayViewModel: NSObject, ObservableObject {
    @Published var downloadProgress: Double = 0            // 用于进度条
    @Published var downloadedItems: [String] = []          // 下载完成后追加
    @Published var player: AVPlayer?                       // 播放器实例
    @Published var musicNames: [String] = []
    @Published var Musics:MusicsDao
    
    override init() {
        
        Musics = MusicsDaoGenrator().getMusicsDao()
        super.init()
        musicNames = Musics.getMusicsName()
        for i in musicNames {
            print(i) // 分隔每个字典的输出
        }
    }
    
    func insertMusicToTable( _ name:String, _ author:String)  {
        Musics.insertMusics( name, author)
    }
    
    func getaMusicsList() -> [String] {
        musicNames = Musics.getMusicsName()
        for i in musicNames {
            print(i) //
        }
        return musicNames
        
    }
    
    
    func downloadFile() {
        guard let url = URL(string: "http://127.0.0.1:5000/uploads/luther.m4p") else {
            print("URL 无效")
            return
        }
        
        // 使用带有 delegate 的 URLSession 来获取进度和完成回调
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        // 注意：用这种方式才能触发 URLSessionDownloadDelegate
        let task = session.downloadTask(with: url)
        task.resume()
    }
}

// MARK: - URLSessionDownloadDelegate
extension DownloadPlayViewModel: URLSessionDownloadDelegate {
    // 下载过程中，多次调用，更新进度
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
    
    // 下载结束后调用，location 是临时文件的位置
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        do {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = docs.appendingPathComponent("luther.m4p")
            
            // 如果目标文件已存在，则先删除
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            // 将临时文件复制到目标位置
            try FileManager.default.copyItem(at: location, to: destinationURL)
            
            DispatchQueue.main.async {
                // 下载完成后追加一条记录
                self.downloadedItems.append("luther.m4p")
                
                // 下载结束时将进度设为100%
                self.downloadProgress = 1.0
                
                // 创建播放器
                self.player = AVPlayer(url: destinationURL)
            }
        } catch {
            print("移动文件出错: \(error.localizedDescription)")
        }
    }
}
