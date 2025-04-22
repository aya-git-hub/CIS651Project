import SwiftUI
import AVKit
import LLM

struct DownloadPlayView: View {
    @StateObject private var viewModel = DownloadPlayViewModel()
    @State private var searchText: String = ""
    @State private var showDeleteAlert: Bool = false
    @State private var selectedMusicForDelete: String? = nil
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showChatView: Bool = false
    
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
                VStack(spacing: 0) {
                    // 搜索栏
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // 可下载的音乐列表
                    List {
                        Section(header: Text("可下载的音乐")) {
                            ForEach(filteredMusicNames, id: \.self) { music in
                                MusicRow(
                                    musicName: music,
                                    isDownloaded: viewModel.downloadedItems.contains(music),
                                    isPlaying: viewModel.currentPlayingMusic == music,
                                    downloadAction: {
                                        if !viewModel.downloadedItems.contains(music) {
                                            viewModel.downloadFile(for: music)
                                        }
                                    },
                                    playAction: {
                                        playMusic(music)
                                    }
                                )
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    // 已下载的音乐列表
                    if !viewModel.downloadedItems.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("已下载的音乐")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            List {
                                ForEach(viewModel.downloadedItems, id: \.self) { music in
                                    DownloadedMusicRow(
                                        musicName: music,
                                        isPlaying: viewModel.currentPlayingMusic == music,
                                        deleteAction: {
                                            viewModel.deleteDownloadedMusic(music)
                                        }
                                    )
                                }
                            }
                            .listStyle(PlainListStyle())
                        }
                        .frame(height: 200)
                    }
                    
                    // 播放器控制区域
                    if let player = viewModel.player {
                        PlayerControlView(player: player)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                    }
                }
                
                // 悬浮聊天按钮
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showChatView = true
                        }) {
                            Image(systemName: "message.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                                .shadow(radius: 3)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("音乐下载")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
        }
        .sheet(isPresented: $showChatView) {
            HuggingFaceChatView()
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

// 搜索栏组件
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("搜索音乐", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// 音乐行组件
struct MusicRow: View {
    let musicName: String
    let isDownloaded: Bool
    let isPlaying: Bool
    let downloadAction: () -> Void
    let playAction: () -> Void
    @State private var showActionSheet = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(musicName)
                    .font(.system(size: 16))
                if isPlaying {
                    Text("正在播放")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Button(action: {
                showActionSheet = true
            }) {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text(musicName),
                message: nil,
                buttons: [
                    .default(Text(isDownloaded ? "已下载" : "下载")) {
                        if !isDownloaded {
                            downloadAction()
                        }
                    },
                    .default(Text(isPlaying ? "停止播放" : "播放")) {
                        if isDownloaded {
                            playAction()
                        } else {
                            let alert = UIAlertController(
                                title: "提示",
                                message: "请先下载音乐",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "确定", style: .default))
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first,
                               let rootViewController = window.rootViewController {
                                rootViewController.present(alert, animated: true)
                            }
                        }
                    },
                    .cancel()
                ]
            )
        }
    }
}

// 已下载音乐行组件
struct DownloadedMusicRow: View {
    let musicName: String
    let isPlaying: Bool
    let deleteAction: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(musicName)
                    .font(.system(size: 16))
                if isPlaying {
                    Text("正在播放")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Button(action: deleteAction) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
}

// 播放器控制组件
struct PlayerControlView: View {
    let player: AVPlayer
    @State private var isPlaying: Bool = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var timeObserverToken: Any?
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                if isPlaying {
                    player.pause()
                } else {
                    player.play()
                }
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading) {
                Text("正在播放")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(getCurrentPlayingName())
                    .font(.system(size: 16))
                    .lineLimit(1)
                
                if duration > 0 {
                    ProgressView(value: currentTime, total: duration)
                        .progressViewStyle(LinearProgressViewStyle())
                }
            }
        }
        .onAppear {
            setupTimeObserver()
            updatePlaybackState()
        }
        .onDisappear {
            removeTimeObserver()
        }
    }
    
    private func getCurrentPlayingName() -> String {
        if let currentItem = player.currentItem,
           let urlAsset = currentItem.asset as? AVURLAsset {
            return urlAsset.url.lastPathComponent
        }
        return "未知音乐"
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            updatePlaybackState()
        }
    }
    
    private func removeTimeObserver() {
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    private func updatePlaybackState() {
        isPlaying = player.timeControlStatus == .playing
        if let currentItem = player.currentItem {
            let itemTime = currentItem.currentTime()
            if itemTime.isValid && !itemTime.isIndefinite {
                currentTime = CMTimeGetSeconds(itemTime)
            }
            
            let itemDuration = currentItem.duration
            if itemDuration.isValid && !itemDuration.isIndefinite {
                duration = CMTimeGetSeconds(itemDuration)
            }
        }
    }
}

struct DownloadPlayView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadPlayView()
    }
}
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(15)
                .textSelection(.enabled)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}
