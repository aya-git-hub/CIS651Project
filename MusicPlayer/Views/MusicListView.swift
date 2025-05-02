import SwiftUI

/// 音乐列表视图
/// 用于：显示可播放的音乐列表
struct MusicListView: View {
    @ObservedObject var viewModel: PlayerTestViewModel
    @State private var showPlayer = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // 音乐列表
                List(viewModel.musicList, id: \.self) { musicURL in
                    Button(action: {
                        // 直接通过 ViewModel 播放选中的音乐
                        viewModel.play(url: musicURL)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(musicURL.lastPathComponent)
                                    .font(.headline)
                                Text("时长: \(formatTime(viewModel.duration))")
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
                .navigationTitle("音乐列表")
                
                // 迷你播放器
                if viewModel.currentMusicIndex > 0 {
                    MiniPlayerView(viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                }
            }
        }
    }
    
    /// 格式化时间显示
    /// - Parameter time: 时间（秒）
    /// - Returns: 格式化后的时间字符串
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 
