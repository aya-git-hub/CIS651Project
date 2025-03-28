import SwiftUI
import AVKit

struct DownloadPlayView: View {
    @StateObject private var viewModel = DownloadPlayViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("下载并播放界面")
                .font(.title)
            
            // 下载按钮
            Button("开始下载") {
                viewModel.downloadFile()
            }
            
            // 进度条（从 0 到 1）
            ProgressView(value: viewModel.downloadProgress, total: 1.0)
                .progressViewStyle(.linear)
                .padding()
            
            // 显示数值进度
            Text("当前下载进度: \(viewModel.downloadProgress * 100, specifier: "%.1f")%")
            
            // 下载完成列表
            List(viewModel.downloadedItems, id: \.self) { item in
                Text(item)
            }
            
            // 如果已经初始化了 player，就用 VideoPlayer 播放
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .frame(height: 200)
                
                // 播放/暂停按钮
                Button(player.timeControlStatus == .playing ? "暂停" : "播放") {
                    if player.timeControlStatus == .playing {
                        player.pause()
                    } else {
                        player.play()
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Download & Play")
    }
}
