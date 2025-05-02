import SwiftUI

/// 迷你播放器视图
/// 用于：在底部显示当前播放的音乐和控制按钮
struct MiniPlayerView: View {
    @ObservedObject var viewModel: PlayerTestViewModel
    @State private var showFullPlayer = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 进度条
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * CGFloat(viewModel.progress), height: 2)
            }
            .frame(height: 2)
            
            // 播放器内容
            HStack(spacing: 15) {
                // 音乐封面（这里使用系统图标代替）
                Image(systemName: "music.note")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                // 音乐信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.currentMusicName)
                        .font(.headline)
                        .lineLimit(1)
                    Text("\(formatTime(viewModel.currentTime)) / \(formatTime(viewModel.duration))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 控制按钮
                HStack(spacing: 20) {
                    Button(action: {
                        viewModel.playPrevious()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.title2)
                    }
                    
                    Button(action: {
                        if viewModel.isPlaying {
                            viewModel.pause()
                        } else {
                            viewModel.resume()
                        }
                    }) {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 30))
                    }
                    
                    Button(action: {
                        viewModel.playNext()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                    }
                }
                .foregroundColor(.primary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(UIColor.systemBackground))
        .shadow(radius: 2)
        .onTapGesture {
            showFullPlayer = true
        }
        .sheet(isPresented: $showFullPlayer) {
            PlayerView(viewModel: viewModel)
        }
    }
    
    /// 格式化时间显示
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 