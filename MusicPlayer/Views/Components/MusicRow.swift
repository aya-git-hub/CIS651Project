import Foundation
import SwiftUI

struct MusicRow: View {
    let musicName: String
    let isDownloaded: Bool
    @ObservedObject var playerViewModel: PlayerTestViewModel
    let downloadAction: () -> Void
    var showDivider: Bool = true // Whether to show bottom divider
    
    // Calculate if current music is playing
    private var isPlaying: Bool {
        playerViewModel.currentMusicName == musicName && playerViewModel.isPlaying
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: isPlaying ? "music.note.list" : "music.note")
                    .foregroundColor(isPlaying ? .blue : .gray)
                    .frame(width: 22, height: 22)
                    .background(
                        Circle()
                            .fill(Color(.systemGray6))
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(musicName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    if isPlaying {
                        Text("Now Playing")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }

                Spacer()

                // Right button, click to show menu
                Menu {
                    if !isDownloaded {
                        Button("Download", action: downloadAction)
                    } else {
                        Button("Downloaded") {}.disabled(true)
                    }
                    if isDownloaded {
                        if isPlaying {
                            Button("Stop", action: {
                                playerViewModel.stop()
                            })
                        } else {
                            Button("Play", action: {
                                playerViewModel.playDownloadedMusic(musicName)
                            })
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                        .padding(6)
                        .background(Circle().fill(Color(.systemGray5)))
                }
                .menuStyle(.automatic)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)

            if showDivider {
                Divider()
                    .padding(.leading, 40)
            }
        }
        .background(Color(.systemBackground))
    }
}
