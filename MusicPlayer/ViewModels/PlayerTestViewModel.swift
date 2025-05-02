import Foundation
import Combine
import SwiftUI
import AVKit

/// 音乐错误枚举
/// 用于：定义音乐播放过程中可能发生的错误类型
enum MusicError: Error {
    case downloadFailed    // 下载失败
    case fileNotFound      // 文件未找到
    case invalidURL        // 无效的URL
    case playbackError     // 播放错误
    
    /// 错误描述
    /// 用于：显示错误信息给用户
    var localizedDescription: String {
        switch self {
        case .downloadFailed:
            return "下载失败"
        case .fileNotFound:
            return "文件未找到"
        case .invalidURL:
            return "无效的URL"
        case .playbackError:
            return "播放错误"
        }
    }
}

/// 通知名称扩展
/// 用于：定义系统通知名称
extension Notification.Name {
    /// 下载完成通知
    /// 用于：通知下载完成事件
    static let downloadComplete = Notification.Name("downloadComplete")
}

/// 播放器测试视图模型
/// 用于：管理播放器测试界面的数据和逻辑
class PlayerTestViewModel: ObservableObject {
    @StateObject private var viewModel = DownloadPlayViewModel.getDownloadPlay()
    
    // MARK: - Published Properties
    
    /// 播放器类型
    /// 用于：选择使用哪种播放器实现
    @Published var playerType: PlayerType = .avPlayer {
        didSet {
            setupPlayer()
        }
    }
    
    /// 是否正在播放
    /// 用于：UI状态显示
    @Published var isPlaying = false
    
    /// 当前播放时间
    /// 用于：显示播放进度
    @Published var currentTime: TimeInterval = 0
    
    /// 音乐总时长
    /// 用于：显示音乐时长
    @Published var duration: TimeInterval = 0
    
    /// 播放进度
    /// 用于：进度条显示
    @Published var progress: Double = 0
    
    /// 播放速率
    /// 用于：控制播放速度
    @Published var playbackRate: Float = 1.0
    
    /// 错误信息
    /// 用于：显示错误提示
    @Published var errorMessage: String?
    
    /// 当前音乐索引
    /// 用于：跟踪当前播放的音乐
    @Published var currentMusicIndex: Int = -1
    
    /// 当前播放的音乐名称
    /// 用于：显示当前播放的音乐名称
    @Published var currentMusicName: String = ""
    
    /// 音乐列表
    /// 用于：存储可播放的音乐URL
    @Published var musicList: [URL] = []
    
    // MARK: - Private Properties
    
    /// 播放器实例
    /// 用于：控制音乐播放
    private var player: PlayerService
    
    /// 可取消的订阅集合
    /// 用于：管理Combine订阅
    private var cancellables = Set<AnyCancellable>()
    
    /// 音乐缓存
    /// 用于：缓存音乐URL
    private let musicCache = MusicCache.shared
    
    // MARK: - Initialization
    
    /// 初始化方法
    /// 用于：设置播放器和加载音乐
    init() {
        player = PlayerFactory.createPlayer(type: .avPlayer)
        setupBindings()
        loadDownloadedMusic()
        setupSync()
    }
    
    // MARK: - Public Methods
    
    /// 播放音乐
    /// - Parameter url: 音乐文件URL
    /// 用于：开始播放指定音乐
    func play(url: URL) {
        // 在后台线程验证文件
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                try self.validateMusicFile(url)
                
                // 在主线程更新UI和播放状态
                DispatchQueue.main.async { [self] in
                    if let index = self.musicList.firstIndex(of: url) {
                        self.currentMusicIndex = index
                    } else {
                        self.musicList.append(url)
                        self.currentMusicIndex = self.musicList.count - 1
                    }
                    
                    // 更新当前音乐名称
                    self.currentMusicName = url.lastPathComponent
                    self.viewModel.currentPlayingMusic = self.currentMusicName
                    
                    // 在后台线程开始播放
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.player.play(url: url)
                    }
                    
                    self.syncPlaybackState()
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleError(error as? MusicError ?? .playbackError)
                }
            }
        }
    }
    
    /// 播放下载的音乐
    /// - Parameter musicName: 音乐文件名
    /// 用于：播放已下载的音乐
    func playDownloadedMusic(_ musicName: String) {
        if let url = getLocalURL(for: musicName) {
            play(url: url)
        } else {
            handleError(.fileNotFound)
        }
    }
    
    /// 播放下一首
    /// 用于：切换到下一首音乐
    func playNext() {
        guard !musicList.isEmpty else { return }
        
        // 在后台线程处理播放
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let nextIndex = (self.currentMusicIndex + 1) % self.musicList.count
            
            // 在主线程更新UI
            DispatchQueue.main.async {
                self.currentMusicIndex = nextIndex
                // 更新当前音乐名称
                self.currentMusicName = self.musicList[nextIndex].lastPathComponent
                self.viewModel.currentPlayingMusic = self.currentMusicName
                self.syncPlaybackState()
            }
            
            // 在后台线程开始播放
            self.player.play(url: self.musicList[nextIndex])
            
            // 预加载下一首
            self.optimizeMusicList()
        }
    }
    
    /// 播放上一首
    /// 用于：切换到上一首音乐
    func playPrevious() {
        guard !musicList.isEmpty else { return }
        
        // 在后台线程处理播放
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let previousIndex = (self.currentMusicIndex - 1 + self.musicList.count) % self.musicList.count
            
            // 在主线程更新UI
            DispatchQueue.main.async {
                self.currentMusicIndex = previousIndex
                // 更新当前音乐名称
                self.currentMusicName = self.musicList[previousIndex].lastPathComponent
                self.viewModel.currentPlayingMusic = self.currentMusicName
                self.syncPlaybackState()
            }
            
            // 在后台线程开始播放
            self.player.play(url: self.musicList[previousIndex])
            
            // 预加载下一首
            self.optimizeMusicList()
        }
    }
    
    /// 暂停播放
    /// 用于：暂停当前播放的音乐
    func pause() {
        player.pause()
        syncPlaybackState()
    }
    
    /// 恢复播放
    /// 用于：从暂停状态恢复播放
    func resume() {
        player.resume()
        syncPlaybackState()
    }
    
    /// 停止播放
    /// 用于：完全停止播放
    func stop() {
        player.stop()
        viewModel.currentPlayingMusic = nil
        syncPlaybackState()
    }
    
    /// 跳转到指定时间
    /// - Parameter time: 目标时间点
    /// 用于：快进/快退功能
    func seek(to time: TimeInterval) {
        player.seek(to: time)
    }
    
    /// 设置播放速率
    /// - Parameter rate: 播放速率
    /// 用于：调整播放速度
    func setPlaybackRate(_ rate: Float) {
        self.playbackRate = rate
        player.setPlaybackRate(rate)
    }
    
    // MARK: - Private Methods
    
    /// 设置播放器
    /// 用于：根据选择的类型创建播放器
    private func setupPlayer() {
        player = PlayerFactory.createPlayer(type: playerType)
        setupBindings()
    }
    
    /// 设置绑定
    /// 用于：设置播放器状态监听
    private func setupBindings() {
        // 设置播放完成回调
        player.setCompletionHandler { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                self?.playNext() // 自动播放下一首
            }
        }
        
        // 设置错误回调
        player.setErrorHandler { [weak self] error in
            DispatchQueue.main.async {
                self?.errorMessage = error.localizedDescription
            }
        }
        
        // 监听播放状态
        Timer.publish(every: 0.1, on: .main, in: .commonModes)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.isPlaying = self.player.isPlaying
                self.currentTime = self.player.currentTime
                self.duration = self.player.duration
                self.progress = self.player.progress
            }
            .store(in: &cancellables)
    }
    
    /// 设置同步
    /// 用于：设置下载完成监听和定期同步
    private func setupSync() {
        // 监听下载完成
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDownloadComplete),
            name: .downloadComplete,
            object: nil
        )
        
        // 定期同步音乐列表
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.loadDownloadedMusic()
        }
    }
    
    /// 处理下载完成
    /// - Parameter notification: 通知对象
    /// 用于：处理下载完成事件
    @objc private func handleDownloadComplete(_ notification: Notification) {
        if let musicName = notification.userInfo?["musicName"] as? String {
            loadDownloadedMusic()
        }
    }
    
    /// 加载下载的音乐
    /// 用于：加载已下载的音乐文件
    private func loadDownloadedMusic() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        for musicName in viewModel.downloadedItems {
            let musicURL = documentsDirectory.appendingPathComponent(musicName)
            if FileManager.default.fileExists(atPath: musicURL.path) {
                if !musicList.contains(musicURL) {
                    musicList.append(musicURL)
                    musicCache.setURL(musicURL, for: musicName)
                }
            }
        }
        
        if currentMusicIndex == -1 && !musicList.isEmpty {
            currentMusicIndex = 0
        }
    }
    
    /// 获取本地音乐URL
    /// - Parameter musicName: 音乐文件名
    /// - Returns: 音乐文件URL
    /// 用于：获取已下载音乐的URL
    private func getLocalURL(for musicName: String) -> URL? {
        if let cachedURL = musicCache.getURL(for: musicName) {
            return cachedURL
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let musicURL = documentsDirectory.appendingPathComponent(musicName)
        return FileManager.default.fileExists(atPath: musicURL.path) ? musicURL : nil
    }
    
    /// 验证音乐文件
    /// - Parameter url: 音乐文件URL
    /// 用于：验证音乐文件是否有效
    private func validateMusicFile(_ url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw MusicError.fileNotFound
        }
        
        // 这里可以添加更多的文件验证逻辑
        // 例如检查文件大小、格式等
    }
    
    /// 处理错误
    /// - Parameter error: 错误对象
    /// 用于：显示错误信息
    private func handleError(_ error: MusicError) {
        errorMessage = error.localizedDescription
    }
    
    /// 同步播放状态
    /// 用于：更新下载播放视图模型的当前播放音乐
    private func syncPlaybackState() {
        viewModel.currentPlayingMusic = currentMusicIndex >= 0 ? 
            musicList[currentMusicIndex].lastPathComponent : nil
    }
    
    /// 优化音乐列表
    /// 用于：预加载下一首音乐
    private func optimizeMusicList() {
        // 在后台线程预加载
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self,
                  self.currentMusicIndex + 1 < self.musicList.count else { return }
            
            let nextURL = self.musicList[self.currentMusicIndex + 1]
            do {
                try self.validateMusicFile(nextURL)
                self.player.prepareToPlay(url: nextURL)
            } catch {
                DispatchQueue.main.async {
                    self.handleError(error as? MusicError ?? .playbackError)
                }
            }
        }
    }
} 
