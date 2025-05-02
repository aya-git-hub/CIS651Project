//
//  PlayerControlView.swift
//  MusicPlayer
//
//  Created by yuao ai on 4/23/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import Foundation
import SwiftUI
import AVKit

struct PlayerControlView: View {
    @ObservedObject var viewModel: PlayerTestViewModel
    let isPlaying: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                if isPlaying {
                    viewModel.pause()
                } else {
                    viewModel.resume()
                }
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading) {
                Text("正在播放")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(viewModel.currentMusicName)
                    .font(.system(size: 16))
                    .lineLimit(1)
                
                if viewModel.duration > 0 {
                    ProgressView(value: viewModel.currentTime, total: viewModel.duration)
                        .progressViewStyle(LinearProgressViewStyle())
                }
            }
        }
    }
}
