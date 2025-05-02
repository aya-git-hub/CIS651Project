import Foundation

/// 播放器类型
enum PlayerType {
    case avPlayer
    case audioPlayer
}

/// 播放器工厂
class PlayerFactory {
    static func createPlayer(type: PlayerType) -> PlayerService {
        switch type {
        case .avPlayer:
            return AVPlayerService()
        case .audioPlayer:
            // 后续实现 AudioPlayerService
            return AVPlayerService()
        }
    }
} 