//
//  MusicRow.swift
//  MusicPlayer
//
//  Created by yuao ai on 4/23/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import Foundation
import SwiftUI
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
