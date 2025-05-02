import Foundation
import AVFoundation

/// 播放器服务协议
/// 定义了音乐播放器的核心功能接口
protocol PlayerService {
    // MARK: - 播放控制
    
    /// 播放指定URL的音乐
    /// - Parameter url: 音乐文件的URL
    /// 用于：开始播放新的音乐文件
    func play(url: URL)
    
    /// 暂停当前播放
    /// 用于：暂停正在播放的音乐
    func pause()
    
    /// 恢复播放
    /// 用于：从暂停状态恢复播放
    func resume()
    
    /// 停止播放
    /// 用于：完全停止播放，重置播放状态
    func stop()
    
    /// 跳转到指定时间点
    /// - Parameter time: 要跳转的时间点
    /// 用于：快进/快退功能
    func seek(to time: TimeInterval)
    
    /// 设置播放速率
    /// - Parameter rate: 播放速率（0.5-2.0）
    /// 用于：调整播放速度
    func setPlaybackRate(_ rate: Float)
    
    /// 预加载音乐资源
    /// - Parameter url: 要预加载的音乐URL
    /// 用于：提前准备下一首音乐，优化播放体验
    func prepareToPlay(url: URL)
    
    // MARK: - 状态获取
    
    /// 是否正在播放
    /// 用于：UI状态显示和播放控制
    var isPlaying: Bool { get }
    
    /// 当前播放时间
    /// 用于：显示播放进度
    var currentTime: TimeInterval { get }
    
    /// 音乐总时长
    /// 用于：显示音乐时长和进度计算
    var duration: TimeInterval { get }
    
    /// 播放进度（0-1）
    /// 用于：进度条显示
    var progress: Double { get }
    
    // MARK: - 回调设置
    
    /// 设置播放完成回调
    /// - Parameter handler: 播放完成时执行的闭包
    /// 用于：处理播放完成后的逻辑（如自动播放下一首）
    func setCompletionHandler(_ handler: @escaping () -> Void)
    
    /// 设置错误处理回调
    /// - Parameter handler: 发生错误时执行的闭包
    /// 用于：处理播放过程中的错误
    func setErrorHandler(_ handler: @escaping (Error) -> Void)
}

/// 播放器状态枚举
/// 用于：表示播放器的当前状态
enum PlayerState {
    case idle      // 空闲状态
    case playing   // 正在播放
    case paused    // 已暂停
    case stopped   // 已停止
    case error(Error) // 发生错误
}

/// 播放器错误枚举
/// 用于：定义播放过程中可能发生的错误类型
enum PlayerError: Error {
    case invalidURL      // URL无效
    case loadFailed      // 加载失败
    case playbackFailed  // 播放失败
    case unknown         // 未知错误
} 