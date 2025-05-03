import SwiftUI

/// Player view
/// Used for: Displaying and controlling music playback
struct PlayerView: View {
    @ObservedObject var viewModel: PlayerTestViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            // Back button
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            .padding()
            
            Spacer()
            
            // Music cover (using system icon as placeholder)
            Image(systemName: "music.note")
                .font(.system(size: 120))
                .foregroundColor(.blue)
                .frame(width: 250, height: 250)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                .padding(.bottom, 40)
            
            // Music information
            VStack(spacing: 10) {
                Text(viewModel.currentMusicName)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Duration: \(formatTime(viewModel.duration))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Progress bar
            VStack {
                Slider(value: Binding(
                    get: { viewModel.progress },
                    set: { newValue in
                        let time = newValue * viewModel.duration
                        viewModel.seek(to: time)
                    }
                ))
                .padding(.horizontal)
                
                HStack {
                    Text(formatTime(viewModel.currentTime))
                    Spacer()
                    Text(formatTime(viewModel.duration))
                }
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
            }
            
            // Control buttons
            HStack(spacing: 40) {
                Button(action: {
                    viewModel.playPrevious()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                }
                
                Button(action: {
                    if viewModel.isPlaying {
                        viewModel.pause()
                    } else {
                        viewModel.resume()
                    }
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 50))
                }
                
                Button(action: {
                    viewModel.playNext()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                }
            }
            .padding(.vertical)
            
            Spacer()
        }
        .padding()
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