import Foundation
import AVFoundation
import Combine

/// AVPlayerService类
/// 实现了PlayerService协议，使用AVFoundation框架提供音乐播放功能
class AVPlayerService: NSObject, PlayerService {
    // MARK: - Properties
    
    /// AVPlayer实例
    /// 用于：控制音乐播放
    private var player: AVPlayer?
    
    /// 时间观察者
    /// 用于：监听播放进度变化
    private var timeObserver: Any?
    
    /// 播放完成回调
    /// 用于：处理播放完成事件
    private var completionHandler: (() -> Void)?
    
    /// 错误处理回调
    /// 用于：处理播放错误
    private var errorHandler: ((Error) -> Void)?
    
    /// 播放器状态
    /// 用于：跟踪播放器当前状态
    @Published private(set) var state: PlayerState = .idle
    
    /// 当前播放时间
    /// 用于：显示播放进度
    @Published private(set) var currentTime: TimeInterval = 0
    
    /// 音乐总时长
    /// 用于：显示音乐时长
    @Published private(set) var duration: TimeInterval = 0
    
    /// 是否正在播放
    /// 用于：UI状态显示
    var isPlaying: Bool {
        if case .playing = state {
            return true
        }
        return false
    }
    
    /// 播放进度
    /// 用于：进度条显示
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    // MARK: - Initialization
    
    /// 初始化方法
    /// 用于：设置音频会话
    override init() {
        super.init()
        setupAudioSession()
    }
    
    /// 析构方法
    /// 用于：清理资源
    deinit {
        cleanup()
    }
    
    // MARK: - PlayerService Implementation
    
    /// 播放音乐
    /// - Parameter url: 音乐文件URL
    /// 用于：开始播放新的音乐
    func play(url: URL) {
        // 先清理当前播放器
        cleanup()
        
        // 创建新的播放项
        let playerItem = AVPlayerItem(url: url)
        
        // 创建新的播放器
        player = AVPlayer(playerItem: playerItem)
        player?.rate = 1.0
        
        // 设置观察者
        setupTimeObserver()
        setupPlayerItemObservers(playerItem)
        
        // 开始播放
        player?.play()
        state = .playing
    }
    
    /// 暂停播放
    /// 用于：暂停当前播放的音乐
    func pause() {
        player?.pause()
        state = .paused
    }
    
    /// 恢复播放
    /// 用于：从暂停状态恢复播放
    func resume() {
        player?.play()
        state = .playing
    }
    
    /// 停止播放
    /// 用于：完全停止播放并重置状态
    func stop() {
        player?.pause()
        player?.seek(to: kCMTimeZero)
        state = .stopped
    }
    
    /// 跳转到指定时间
    /// - Parameter time: 目标时间点
    /// 用于：快进/快退功能
    func seek(to time: TimeInterval) {
        let time = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: time)
    }
    
    /// 设置播放速率
    /// - Parameter rate: 播放速率（0.5-2.0）
    /// 用于：调整播放速度
    func setPlaybackRate(_ rate: Float) {
        guard rate >= 0.5 && rate <= 2.0 else { return }
        player?.rate = rate
    }
    
    /// 设置播放完成回调
    /// - Parameter handler: 回调闭包
    /// 用于：处理播放完成事件
    func setCompletionHandler(_ handler: @escaping () -> Void) {
        completionHandler = handler
    }
    
    /// 设置错误处理回调
    /// - Parameter handler: 回调闭包
    /// 用于：处理播放错误
    func setErrorHandler(_ handler: @escaping (Error) -> Void) {
        errorHandler = handler
    }
    
    /// 预加载音乐资源
    /// - Parameter url: 音乐文件URL
    /// 用于：提前准备下一首音乐
    func prepareToPlay(url: URL) {
        // 创建新的播放项
        let playerItem = AVPlayerItem(url: url)
        
        // 设置预加载参数
        playerItem.preferredForwardBufferDuration = 10 // 预加载10秒
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        
        // 创建预加载播放器
        let preloadPlayer = AVPlayer(playerItem: playerItem)
        
        // 设置音频会话
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            errorHandler?(error)
        }
        
        // 不设置时间观察者，因为这只是预加载
        // 不替换当前播放器，因为当前音乐还在播放
    }
    
    // MARK: - Private Methods
    
    /// 设置音频会话
    /// 用于：配置音频播放环境
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setMode(AVAudioSessionModeDefault)
            try audioSession.setActive(true)
        } catch {
            state = .error(error)
            errorHandler?(error)
        }
    }
    
    /// 设置时间观察者
    /// 用于：监听播放进度变化
    private func setupTimeObserver() {
        // 确保没有旧的时间观察者
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        // 创建新的时间观察者
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = CMTimeGetSeconds(time)
            
            if let duration = self.player?.currentItem?.duration {
                self.duration = CMTimeGetSeconds(duration)
            }
        }
    }
    
    /// 设置播放项观察者
    /// - Parameter playerItem: 要观察的播放项
    /// 用于：监听播放状态变化
    private func setupPlayerItemObservers(_ playerItem: AVPlayerItem) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidPlayToEndTime),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        playerItem.observe(\.status) { [weak self] item, _ in
            guard let self = self else { return }
            
            switch item.status {
            case .readyToPlay:
                self.duration = CMTimeGetSeconds(item.duration)
            case .failed:
                if let error = item.error {
                    self.state = .error(error)
                    self.errorHandler?(error)
                }
            default:
                break
            }
        }
    }
    
    /// 清理资源
    /// 用于：释放播放器资源
    private func cleanup() {
        // 先移除时间观察者
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        // 停止播放并重置状态
        player?.pause()
        player = nil
        state = .idle
        currentTime = 0
        duration = 0
    }
    
    // MARK: - Notification Handlers
    
    /// 播放完成处理
    /// 用于：处理音乐播放完成事件
    @objc private func playerItemDidPlayToEndTime() {
        state = .stopped
        completionHandler?()
    }
} 