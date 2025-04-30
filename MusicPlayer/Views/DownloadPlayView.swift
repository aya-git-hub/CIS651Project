
import SwiftUI
import AVKit
import LLM

struct DownloadPlayView: View {
    @StateObject private var viewModel = DownloadPlayViewModel.getDownloadPlay()
    @State private var searchText: String = ""
    @State private var showDeleteAlert = false
    @State private var selectedMusicForDelete: String? = nil
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showChatView = false
    var authViewModel = AuthViewModel.getAuth()
    @State private var navigateToLogin = false
    @State private var is_Playing: Bool = false
    
    
    // 根据搜索文本过滤音乐名称
    var filteredMusicNames: [String] {
        if searchText.isEmpty {
            return viewModel.availableMusicItems
        } else {
            return viewModel.availableMusicItems.filter {
                $0.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 主内容
                VStack(spacing: 0) {
                    // 搜索栏
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // 可下载音乐列表
                    List {
                        Section(header: Text("Downloadable Music")) {
                            ForEach(filteredMusicNames, id: \.self) { music in
                                MusicRow(
                                    musicName: music,
                                    isDownloaded: viewModel.downloadedItems.contains(music),
                                    isPlaying: viewModel.currentPlayingMusic == music,
                                    downloadAction: {
                                        if !viewModel.downloadedItems.contains(music) {
                                            viewModel.downloadWithMetadata(for: music)
                                        }
                                    },
                                    playAction: {
                                        viewModel.iWantToPlay(music)
                                        
                                    }
                                )
                            }
                        }
                    }
                    .listStyle(PlainListStyle())

                    // 已下载音乐列表
                    /*if !viewModel.downloadedItems.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Downloaded Music")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top, 8)

                            List {
                                ForEach(viewModel.downloadedItems, id: \.self) { music in
                                    DownloadedMusicRow(
                                        musicName: music,
                                        isPlaying: viewModel.currentPlayingMusic == music,
                                        deleteAction: {
                                            viewModel.deleteMusicEverywhere(music)
                                        }
                                    )
                                }
                            }
                            .listStyle(PlainListStyle())
                        }
                        .frame(height: 200)
                    }*/

                    // 播放器控制区域
                    if let player = viewModel.player {
                        PlayerControlView(player: player,isPlaying: viewModel.currentPlayingMusic != nil)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                    }
                }

                // 退出登录按钮（固定左上角）
                VStack {
                    HStack {
                        Button("🚪 退出登录") {
                            authViewModel.signOut()
                            navigateToLogin = true
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                        .padding(.leading)
                        Spacer()
                    }
                    Spacer()
                }
                
                // 悬浮可拖拽聊天按钮
                DraggableChatButton {
                    showChatView = true
                }
            }
            .navigationTitle("Search Your Music")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
        }
        .sheet(isPresented: $showChatView) {
            AiChatView()
        }
    }

    private func playMusic(_ musicName: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let musicURL = documentsDirectory.appendingPathComponent(musicName)
        
        if FileManager.default.fileExists(atPath: musicURL.path) {
            viewModel.playMusic(musicName)
        } else {
            alertMessage = "音乐文件不存在，请先下载"
            showAlert = true
        }
    }
}

struct DownloadPlayView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadPlayView()
    }
}
