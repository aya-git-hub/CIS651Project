import SwiftUI
import AVKit

struct DownloadPlayView: View {
    @StateObject private var viewModel = DownloadPlayViewModel()
    @State private var newMusicName: String = ""
    @State private var newMusicAuthor: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("下载并播放界面")
                    .font(.title)
                
                // 下载按钮（可以保留用于测试默认下载）
                Button("开始下载默认") {
                    viewModel.downloadFile(for: "luther.m4p")
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // 进度条
                ProgressView(value: viewModel.downloadProgress, total: 1.0)
                    .progressViewStyle(.linear)
                    .padding()
                
                Text("当前下载进度: \(viewModel.downloadProgress * 100, specifier: "%.1f")%")
                
                // 显示错误信息（如下载失败）
                if let errorMsg = viewModel.errorMessage {
                    Text(errorMsg)
                        .foregroundColor(.red)
                }
                
                // 下载完成列表
                List(viewModel.downloadedItems, id: \.self) { item in
                    Text(item)
                }
                .frame(height: 200)
                
                // 播放器区域
                if let player = viewModel.player {
                    VideoPlayer(player: player)
                        .frame(height: 200)
                    
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
                
                // 获取音乐列表按钮
                Button("获取音乐列表") {
                    _ = viewModel.getaMusicsList()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // 插入音乐的输入区域：两个文本框和一个按钮
                HStack {
                    TextField("音乐名称", text: $newMusicName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("作者", text: $newMusicAuthor)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("插入音乐") {
                        if newMusicName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                            newMusicAuthor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            alertMessage = "请填写完整的音乐名称和作者信息！"
                            showAlert = true
                        } else {
                            viewModel.insertMusicToTable(newMusicName, newMusicAuthor)
                            newMusicName = ""
                            newMusicAuthor = ""
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                
                // 显示所有 musicNames，每行显示一个。点击某个音乐名称触发下载
                VStack(alignment: .leading, spacing: 8) {
                    Text("音乐列表")
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    ForEach(viewModel.musicNames, id: \.self) { music in
                        Button(action: {
                            // 调用下载方法，传入所选音乐名称
                            viewModel.downloadFile(for: music)
                        }) {
                            Text(music)
                                .foregroundColor(.primary)
                                .padding(.vertical, 4)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding()
            }
            .padding()
            .navigationTitle("Download & Play")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("警告"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("确定")))
            }
        }
    }
}
