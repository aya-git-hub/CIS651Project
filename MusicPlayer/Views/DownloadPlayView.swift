import SwiftUI
import AVKit
import LLM

struct DownloadPlayView: View {
    @StateObject private var viewModel = DownloadPlayViewModel.getDownloadPlay()
    @ObservedObject var playerViewModel: PlayerTestViewModel
    @State private var searchText: String = ""
    @State private var showDeleteAlert = false
    @State private var selectedMusicForDelete: String? = nil
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showChatView = false
    var authViewModel = AuthViewModel.getAuth()
    @State private var navigateToLogin = false
    
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
                // 背景色
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                // 主内容
                VStack(spacing: 16) {
                    // 搜索栏
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // 可下载音乐列表
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredMusicNames, id: \.self) { music in
                                MusicRow(
                                    musicName: music,
                                    isDownloaded: viewModel.downloadedItems.contains(music),
                                    playerViewModel: playerViewModel,
                                    downloadAction: {
                                        if !viewModel.downloadedItems.contains(music) {
                                            viewModel.downloadWithMetadata(for: music)
                                        }
                                    }/*,
                                    playAction: {
                                        if viewModel.downloadedItems.contains(music) {
                                            if viewModel.currentPlayingMusic == music {
                                                // 如果当前正在播放这首音乐，则停止播放
                                                playerViewModel.stop()
                                            } else {
                                                // 否则开始播放这首音乐
                                                playerViewModel.playDownloadedMusic(music)
                                            }
                                        } else {
                                            alertMessage = "请先下载音乐"
                                            showAlert = true
                                        }
                                    }*/
                                )
                                .padding(.horizontal)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                )
                                .padding(.horizontal, 8)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.55)
                    
                    Spacer()
                }
                .padding(.bottom, playerViewModel.currentMusicIndex >= 0 ? 80 : 16)
                
                // 悬浮可拖拽聊天按钮
                DraggableChatButton {
                    showChatView = true
                }
                
                // 迷你播放器
                if playerViewModel.currentMusicIndex >= 0 {
                    VStack {
                        Spacer()
                        MiniPlayerView(viewModel: playerViewModel)
                            .transition(.move(edge: .bottom))
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(UIColor.systemBackground))
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -5)
                            )
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
        }
        .navigationTitle("Search Your Music")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ProfileMenuView()
                    .environmentObject(authViewModel)
            }
        }
        .sheet(isPresented: $showChatView) {
            AiChatView()
        }
    }
}
