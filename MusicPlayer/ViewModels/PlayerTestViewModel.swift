import Foundation
import Combine
import SwiftUI
import AVKit

/// Music error enumeration
/// Used for: defining possible error types during music playback
enum MusicError: Error {
    case downloadFailed    // Download failed
    case fileNotFound      // File not found
    case invalidURL        // Invalid URL
    case playbackError     // Playback error
    
    /// Error description
    /// Used for: displaying error messages to users
    var localizedDescription: String {
        switch self {
        case .downloadFailed:
            return "Download failed"
        case .fileNotFound:
            return "File not found"
        case .invalidURL:
            return "Invalid URL"
        case .playbackError:
            return "Playback error"
        }
    }
}

/// Notification name extension
/// Used for: defining system notification names
extension Notification.Name {
    /// Download completion notification
    /// Used for: notifying download completion events
    static let downloadComplete = Notification.Name("downloadComplete")
}

/// Player test view model
/// Used for: managing data and logic for the player test interface
class PlayerTestViewModel: ObservableObject {
    @StateObject private var viewModel = DownloadPlayViewModel.getDownloadPlay()
    
    // MARK: - Published Properties
    
    /// Player type
    /// Used for: selecting which player implementation to use
    @Published var playerType: PlayerType = .avPlayer {
        didSet {
            setupPlayer()
        }
    }
    
    /// Whether currently playing
    /// Used for: UI state display
    @Published var isPlaying = false
    
    /// Current playback time
    /// Used for: displaying playback progress
    @Published var currentTime: TimeInterval = 0
    
    /// Total music duration
    /// Used for: displaying music duration
    @Published var duration: TimeInterval = 0
    
    /// Playback progress
    /// Used for: progress bar display
    @Published var progress: Double = 0
    
    /// Playback rate
    /// Used for: controlling playback speed
    @Published var playbackRate: Float = 1.0
    
    /// Error message
    /// Used for: displaying error prompts
    @Published var errorMessage: String?
    
    /// Current music index
    /// Used for: tracking currently playing music
    @Published var currentMusicIndex: Int = -1
    
    /// Currently playing music name
    /// Used for: displaying current music name
    @Published var currentMusicName: String = ""
    
    /// Music list
    /// Used for: storing playable music URLs
    @Published var musicList: [URL] = []
    
    // MARK: - Private Properties
    
    /// Player instance
    /// Used for: controlling music playback
    private var player: PlayerService
    
    /// Cancellable subscriptions collection
    /// Used for: managing Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Music cache
    /// Used for: caching music URLs
    private let musicCache = MusicCache.shared
    
    // MARK: - Initialization
    
    /// Initialization method
    /// Used for: setting up player and loading music
    init() {
        player = PlayerFactory.createPlayer(type: .avPlayer)
        setupBindings()
        loadDownloadedMusic()
        setupSync()
    }
    
    // MARK: - Public Methods
    
    /// Play music
    /// - Parameter url: Music file URL
    /// Used for: starting playback of specified music
    func play(url: URL) {
        // Validate file in background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                try self.validateMusicFile(url)
                
                // Update UI and playback state on main thread
                DispatchQueue.main.async { [self] in
                    if let index = self.musicList.firstIndex(of: url) {
                        self.currentMusicIndex = index
                    } else {
                        self.musicList.append(url)
                        self.currentMusicIndex = self.musicList.count - 1
                    }
                    
                    // Update current music name and playback state
                    self.currentMusicName = url.lastPathComponent
                    self.viewModel.currentPlayingMusic = self.currentMusicName
                    self.isPlaying = true
                    
                    // Start playback in background thread
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
    
    /// Play downloaded music
    /// - Parameter musicName: Music file name
    /// Used for: playing downloaded music
    func playDownloadedMusic(_ musicName: String) {
        if let url = getLocalURL(for: musicName) {
            play(url: url)
        } else {
            handleError(.fileNotFound)
        }
    }
    
    /// Play next track
    /// Used for: switching to next music
    func playNext() {
        guard !musicList.isEmpty else { return }
        
        // Handle playback in background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let nextIndex = (self.currentMusicIndex + 1) % self.musicList.count
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.currentMusicIndex = nextIndex
                // Update current music name
                self.currentMusicName = self.musicList[nextIndex].lastPathComponent
                self.viewModel.currentPlayingMusic = self.currentMusicName
                self.syncPlaybackState()
            }
            
            // Start playback in background thread
            self.player.play(url: self.musicList[nextIndex])
            
            // Preload next track
            self.optimizeMusicList()
        }
    }
    
    /// Play previous track
    /// Used for: switching to previous music
    func playPrevious() {
        guard !musicList.isEmpty else { return }
        
        // Handle playback in background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let previousIndex = (self.currentMusicIndex - 1 + self.musicList.count) % self.musicList.count
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.currentMusicIndex = previousIndex
                // Update current music name
                self.currentMusicName = self.musicList[previousIndex].lastPathComponent
                self.viewModel.currentPlayingMusic = self.currentMusicName
                self.syncPlaybackState()
            }
            
            // Start playback in background thread
            self.player.play(url: self.musicList[previousIndex])
            
            // Preload next track
            self.optimizeMusicList()
        }
    }
    
    /// Pause playback
    /// Used for: pausing current music playback
    func pause() {
        player.pause()
        syncPlaybackState()
    }
    
    /// Resume playback
    /// Used for: resuming playback from paused state
    func resume() {
        player.resume()
        syncPlaybackState()
    }
    
    /// Stop playback
    /// Used for: completely stopping playback
    func stop() {
        player.stop()
        viewModel.currentPlayingMusic = nil
        currentMusicName = ""
        currentMusicIndex = -1
        isPlaying = false
        syncPlaybackState()
    }
    
    /// Seek to specified time
    /// - Parameter time: Target time point
    /// Used for: fast forward/rewind functionality
    func seek(to time: TimeInterval) {
        player.seek(to: time)
    }
    
    /// Set playback rate
    /// - Parameter rate: Playback rate
    /// Used for: adjusting playback speed
    func setPlaybackRate(_ rate: Float) {
        self.playbackRate = rate
        player.setPlaybackRate(rate)
    }
    
    // MARK: - Private Methods
    
    /// Set up player
    /// Used for: creating player based on selected type
    private func setupPlayer() {
        player = PlayerFactory.createPlayer(type: playerType)
        setupBindings()
    }
    
    /// Set up bindings
    /// Used for: setting up player state monitoring
    private func setupBindings() {
        // Set up playback completion callback
        player.setCompletionHandler { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                self?.playNext() // Auto-play next track
            }
        }
        
        // Set up error callback
        player.setErrorHandler { [weak self] error in
            DispatchQueue.main.async {
                self?.errorMessage = error.localizedDescription
            }
        }
        
        // Monitor playback state
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
    
    /// Set up synchronization
    /// Used for: setting up download completion monitoring and periodic synchronization
    private func setupSync() {
        // Monitor download completion
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDownloadComplete),
            name: .downloadComplete,
            object: nil
        )
        
        // Periodically synchronize music list
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.loadDownloadedMusic()
        }
    }
    
    /// Handle download completion
    /// - Parameter notification: Notification object
    /// Used for: handling download completion events
    @objc private func handleDownloadComplete(_ notification: Notification) {
        if let musicName = notification.userInfo?["musicName"] as? String {
            loadDownloadedMusic()
        }
    }
    
    /// Load downloaded music
    /// Used for: loading downloaded music files
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
    
    /// Get local music URL
    /// - Parameter musicName: Music file name
    /// - Returns: Music file URL
    /// Used for: getting URL of downloaded music
    private func getLocalURL(for musicName: String) -> URL? {
        if let cachedURL = musicCache.getURL(for: musicName) {
            return cachedURL
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let musicURL = documentsDirectory.appendingPathComponent(musicName)
        return FileManager.default.fileExists(atPath: musicURL.path) ? musicURL : nil
    }
    
    /// Validate music file
    /// - Parameter url: Music file URL
    /// Used for: validating if music file is valid
    private func validateMusicFile(_ url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw MusicError.fileNotFound
        }
        
        // Additional file validation logic can be added here
        // For example, checking file size, format, etc.
    }
    
    /// Handle error
    /// - Parameter error: Error object
    /// Used for: displaying error messages
    private func handleError(_ error: MusicError) {
        errorMessage = error.localizedDescription
    }
    
    /// Synchronize playback state
    /// Used for: updating current playing music in download play view model
    private func syncPlaybackState() {
        viewModel.currentPlayingMusic = currentMusicIndex >= 0 ? 
            musicList[currentMusicIndex].lastPathComponent : nil
    }
    
    /// Optimize music list
    /// Used for: preloading next music
    private func optimizeMusicList() {
        // Preload in background thread
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
