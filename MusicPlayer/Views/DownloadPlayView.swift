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
    
    // Filter music names based on search text
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
                // Background color
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                // Main content
                VStack(spacing: 16) {
                    // Search bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Downloadable music list
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
                                                // If this music is currently playing, stop it
                                                playerViewModel.stop()
                                            } else {
                                                // Otherwise start playing this music
                                                playerViewModel.playDownloadedMusic(music)
                                            }
                                        } else {
                                            alertMessage = "Please download the music first"
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
                
                // Floating draggable chat button
                DraggableChatButton {
                    showChatView = true
                }
                
                // Mini player
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
                    title: Text("Notice"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationTitle("Search Your Music")
        .sheet(isPresented: $showChatView) {
            AiChatView()
        }
    }
}
