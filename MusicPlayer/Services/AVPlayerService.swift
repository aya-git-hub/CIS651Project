import Foundation
import AVFoundation
import Combine

/// AVPlayerService class
/// Implements the PlayerService protocol, providing music playback functionality using AVFoundation framework
class AVPlayerService: NSObject, PlayerService {
    // MARK: - Properties
    
    /// AVPlayer instance
    /// Used for: controlling music playback
    private var player: AVPlayer?
    
    /// Time observer
    /// Used for: monitoring playback progress changes
    private var timeObserver: Any?
    
    /// Playback completion callback
    /// Used for: handling playback completion events
    private var completionHandler: (() -> Void)?
    
    /// Error handling callback
    /// Used for: handling playback errors
    private var errorHandler: ((Error) -> Void)?
    
    /// Player state
    /// Used for: tracking current player state
    @Published private(set) var state: PlayerState = .idle
    
    /// Current playback time
    /// Used for: displaying playback progress
    @Published private(set) var currentTime: TimeInterval = 0
    
    /// Total music duration
    /// Used for: displaying music duration
    @Published private(set) var duration: TimeInterval = 0
    
    /// Whether currently playing
    /// Used for: UI state display
    var isPlaying: Bool {
        if case .playing = state {
            return true
        }
        return false
    }
    
    /// Playback progress
    /// Used for: progress bar display
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    // MARK: - Initialization
    
    /// Initialization method
    /// Used for: setting up audio session
    override init() {
        super.init()
        setupAudioSession()
    }
    
    /// Deinitialization method
    /// Used for: cleaning up resources
    deinit {
        cleanup()
    }
    
    // MARK: - PlayerService Implementation
    
    /// Play music
    /// - Parameter url: Music file URL
    /// Used for: starting playback of new music
    func play(url: URL) {
        // First clean up current player
        cleanup()
        
        // Create new player item
        let playerItem = AVPlayerItem(url: url)
        
        // Create new player
        player = AVPlayer(playerItem: playerItem)
        player?.rate = 1.0
        
        // Set up observers
        setupTimeObserver()
        setupPlayerItemObservers(playerItem)
        
        // Start playback
        player?.play()
        state = .playing
    }
    
    /// Pause playback
    /// Used for: pausing current music playback
    func pause() {
        player?.pause()
        state = .paused
    }
    
    /// Resume playback
    /// Used for: resuming playback from paused state
    func resume() {
        player?.play()
        state = .playing
    }
    
    /// Stop playback
    /// Used for: completely stopping playback and resetting state
    func stop() {
        player?.pause()
        player?.seek(to: kCMTimeZero)
        state = .stopped
    }
    
    /// Seek to specified time
    /// - Parameter time: Target time point
    /// Used for: fast forward/rewind functionality
    func seek(to time: TimeInterval) {
        let time = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: time)
    }
    
    /// Set playback rate
    /// - Parameter rate: Playback rate (0.5-2.0)
    /// Used for: adjusting playback speed
    func setPlaybackRate(_ rate: Float) {
        guard rate >= 0.5 && rate <= 2.0 else { return }
        player?.rate = rate
    }
    
    /// Set playback completion callback
    /// - Parameter handler: Callback closure
    /// Used for: handling playback completion events
    func setCompletionHandler(_ handler: @escaping () -> Void) {
        completionHandler = handler
    }
    
    /// Set error handling callback
    /// - Parameter handler: Callback closure
    /// Used for: handling playback errors
    func setErrorHandler(_ handler: @escaping (Error) -> Void) {
        errorHandler = handler
    }
    
    /// Preload music resources
    /// - Parameter url: Music file URL
    /// Used for: preparing next music in advance
    func prepareToPlay(url: URL) {
        // Create new player item
        let playerItem = AVPlayerItem(url: url)
        
        // Set preload parameters
        playerItem.preferredForwardBufferDuration = 10 // Preload 10 seconds
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        
        // Create preload player
        let preloadPlayer = AVPlayer(playerItem: playerItem)
        
        // Set up audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            errorHandler?(error)
        }
        
        // Don't set up time observer as this is just preloading
        // Don't replace current player as current music is still playing
    }
    
    // MARK: - Private Methods
    
    /// Set up audio session
    /// Used for: configuring audio playback environment
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
    
    /// Set up time observer
    /// Used for: monitoring playback progress changes
    private func setupTimeObserver() {
        // Ensure no old time observer exists
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        // Create new time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = CMTimeGetSeconds(time)
            
            if let duration = self.player?.currentItem?.duration {
                self.duration = CMTimeGetSeconds(duration)
            }
        }
    }
    
    /// Set up player item observers
    /// - Parameter playerItem: Player item to observe
    /// Used for: monitoring playback state changes
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
    
    /// Clean up resources
    /// Used for: releasing player resources
    private func cleanup() {
        // First remove time observer
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        // Stop playback and reset state
        player?.pause()
        player = nil
        state = .idle
        currentTime = 0
        duration = 0
    }
    
    // MARK: - Notification Handlers
    
    /// Playback completion handler
    /// Used for: handling music playback completion events
    @objc private func playerItemDidPlayToEndTime() {
        state = .stopped
        completionHandler?()
    }
} 