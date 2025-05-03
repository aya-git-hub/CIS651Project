import SwiftUI

/// Music list view
/// Used for: Displaying playable music list
struct MusicListView: View {
    @ObservedObject var viewModel: PlayerTestViewModel
    @State private var showPlayer = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Music list
                List(viewModel.musicList, id: \.self) { musicURL in
                    Button(action: {
                        // Play selected music directly through ViewModel
                        viewModel.play(url: musicURL)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(musicURL.lastPathComponent)
                                    .font(.headline)
                                Text("Duration: \(formatTime(viewModel.duration))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if viewModel.currentMusicIndex == viewModel.musicList.firstIndex(of: musicURL) {
                                Image(systemName: "play.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .navigationTitle("Music List")
                
                // Mini player
                if viewModel.currentMusicIndex >= 0 {
                    MiniPlayerView(viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                }
            }
        }
    }
    
    /// Format time display
    /// - Parameter time: Time in seconds
    /// - Returns: Formatted time string
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 
