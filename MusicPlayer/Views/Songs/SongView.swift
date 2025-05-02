import AVFoundation
import SwiftUI

struct SongView: View {
    var song: Song {
        mediaPlayerState.currentSong
    }
    
    @EnvironmentObject var mediaPlayerState: MediaPlayerState
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var isSliderEditing = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {}
    }

    private func setupAudio() {
    }
    
    private func timeString(for seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    SongView()
        .environmentObject(MediaPlayerState())
}
