import Foundation
import AVFoundation

/// Player service protocol
/// Defines the core functionality interface for music player
protocol PlayerService {
    // MARK: - Playback Control
    
    /// Play music from specified URL
    /// - Parameter url: URL of the music file
    /// Used for: starting playback of a new music file
    func play(url: URL)
    
    /// Pause current playback
    /// Used for: pausing currently playing music
    func pause()
    
    /// Resume playback
    /// Used for: resuming playback from paused state
    func resume()
    
    /// Stop playback
    /// Used for: completely stopping playback and resetting playback state
    func stop()
    
    /// Seek to specified time point
    /// - Parameter time: Time point to seek to
    /// Used for: fast forward/rewind functionality
    func seek(to time: TimeInterval)
    
    /// Set playback rate
    /// - Parameter rate: Playback rate (0.5-2.0)
    /// Used for: adjusting playback speed
    func setPlaybackRate(_ rate: Float)
    
    /// Preload music resources
    /// - Parameter url: URL of music to preload
    /// Used for: preparing next music in advance to optimize playback experience
    func prepareToPlay(url: URL)
    
    // MARK: - State Access
    
    /// Whether currently playing
    /// Used for: UI state display and playback control
    var isPlaying: Bool { get }
    
    /// Current playback time
    /// Used for: displaying playback progress
    var currentTime: TimeInterval { get }
    
    /// Total music duration
    /// Used for: displaying music duration and progress calculation
    var duration: TimeInterval { get }
    
    /// Playback progress (0-1)
    /// Used for: progress bar display
    var progress: Double { get }
    
    // MARK: - Callback Setup
    
    /// Set playback completion callback
    /// - Parameter handler: Closure to execute when playback completes
    /// Used for: handling post-playback logic (e.g., auto-playing next track)
    func setCompletionHandler(_ handler: @escaping () -> Void)
    
    /// Set error handling callback
    /// - Parameter handler: Closure to execute when an error occurs
    /// Used for: handling errors during playback
    func setErrorHandler(_ handler: @escaping (Error) -> Void)
}

/// Player state enumeration
/// Used for: representing current state of the player
enum PlayerState {
    case idle      // Idle state
    case playing   // Currently playing
    case paused    // Paused
    case stopped   // Stopped
    case error(Error) // Error occurred
}

/// Player error enumeration
/// Used for: defining possible error types during playback
enum PlayerError: Error {
    case invalidURL      // Invalid URL
    case loadFailed      // Load failed
    case playbackFailed  // Playback failed
    case unknown         // Unknown error
} 