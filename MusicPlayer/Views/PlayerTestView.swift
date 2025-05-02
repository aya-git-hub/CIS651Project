import SwiftUI

/// 播放器测试视图
/// 用于：测试音乐播放功能
struct PlayerTestView: View {
    @ObservedObject var viewModel: PlayerTestViewModel
    
    var body: some View {
        MusicListView(viewModel: viewModel)
    }
}
