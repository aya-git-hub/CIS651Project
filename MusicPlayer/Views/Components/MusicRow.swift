import Foundation
import SwiftUI

struct MusicRow: View {
    let musicName: String
    let isDownloaded: Bool
    let isPlaying: Bool
    let downloadAction: () -> Void
    let playAction: () -> Void
    var showDivider: Bool = true // 是否显示底部分隔线
    @StateObject private var viewModel = DownloadPlayViewModel.getDownloadPlay()
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
                        Text("正在播放")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }

                Spacer()

                // 右侧按钮，点击弹出小菜单
                Menu {
                    if !isDownloaded {
                        Button("下载", action: downloadAction)
                    } else {
                        Button("已下载") {}.disabled(true)
                    }
                    if isDownloaded {
                        Button(action: playAction){switch viewModel.playStatus {
                        case .playing:
                            Text("Stop")           // 正在播放 → 显示“暂停”
                        case .pause:
                            Text("Replay")       // 暂停中 → “继续播放”
                        case .stopped:
                            Text("Play")           // 停止状态 → “播放”
                        }}
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
