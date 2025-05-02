import SwiftUI

/// 播放器视图
/// 用于：显示和控制音乐播放
struct PlayerView: View {
    @ObservedObject var viewModel: PlayerTestViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            // 返回按钮
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
            
            // 音乐封面（这里使用系统图标代替）
            Image(systemName: "music.note")
                .font(.system(size: 120))
                .foregroundColor(.blue)
                .frame(width: 250, height: 250)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                .padding(.bottom, 40)
            
            // 音乐信息
            VStack(spacing: 10) {
                Text(viewModel.currentMusicName)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("时长: \(formatTime(viewModel.duration))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 进度条
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
            
            // 控制按钮
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
    
    /// 格式化时间显示
    /// - Parameter time: 时间（秒）
    /// - Returns: 格式化后的时间字符串
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 