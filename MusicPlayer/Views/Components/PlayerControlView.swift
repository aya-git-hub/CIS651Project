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
