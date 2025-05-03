import Foundation

/// Player type
enum PlayerType {
    case avPlayer
    case audioPlayer
}

/// Player factory
class PlayerFactory {
    static func createPlayer(type: PlayerType) -> PlayerService {
        switch type {
        case .avPlayer:
            return AVPlayerService()
        case .audioPlayer:
            // AudioPlayerService implementation to be added later
            return AVPlayerService()
        }
    }
} 