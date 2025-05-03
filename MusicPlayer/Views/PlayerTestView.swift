import SwiftUI

/// Player test view
/// Used for: Testing music playback functionality
struct PlayerTestView: View {
    @ObservedObject var viewModel: PlayerTestViewModel
    
    var body: some View {
        MusicListView(viewModel: viewModel)
    }
}
