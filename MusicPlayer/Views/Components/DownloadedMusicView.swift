//
//  DownloadMusicView.swift
//  MusicPlayer
//
//  Created by yuao ai on 4/30/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import Foundation
import SwiftUI
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
