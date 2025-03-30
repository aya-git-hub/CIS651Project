import SwiftUI
import AVKit

struct DownloadPlayView: View {
    @StateObject private var viewModel = DownloadPlayViewModel()
    @State private var newMusicName: String = ""
    @State private var newMusicAuthor: String = ""
    
    var body: some View {
        ScrollView {  // 如果内容较多，可以用 ScrollView 包裹
            VStack(spacing: 20) {
                Text("下载并播放界面")
                    .font(.title)
                
                // 下载按钮
                Button("开始下载") {
                    viewModel.downloadFile()
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
                
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
                .frame(height: 200)
                
                // 播放器区域
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
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                // 新增按钮：调用 getaMusicsList()
                Button("获取音乐列表") {
                    _ = viewModel.getaMusicsList()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // 新增输入区域：两个文本框和一个按钮，调用 insertMusicToTable()
                HStack {
                    TextField("音乐名称", text: $newMusicName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("作者", text: $newMusicAuthor)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("插入音乐") {
                        viewModel.insertMusicToTable(newMusicName, newMusicAuthor)
                        // 清空输入框
                        newMusicName = ""
                        newMusicAuthor = ""
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            .padding()
            .navigationTitle("Download & Play")
        }
    }
}
