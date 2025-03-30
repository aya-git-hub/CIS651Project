//
//  PlayMusicView.swift
//  MusicPlayer
//
//  Created by 王钊 on 3/29/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//
import AVKit
import SwiftUI

// List View: 展示当前用户保存的歌曲
struct LibraryView: View {
    @StateObject var viewModel = LibraryViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.songs, id: \.self) { songName in
                NavigationLink(destination: MusicPlayerView(songName: songName)) {
                    Text(songName)
                        .padding()
                }
            }
            .navigationTitle("My Music")
            .onAppear {
                viewModel.loadSongs()
            }
        }
    }
}

// Player View: 播放器界面展示当前歌曲和音频控制
struct MusicPlayerView: View {
    let songName: String
    @ObservedObject var player = AudioPlayer()  // AudioPlayer 用于管理音频播放（需在项目中实现）
    
    var body: some View {
        VStack {
            Text("Now Playing: \(songName)")
                .font(.title)
                .padding()
            
            Spacer()
            
            Image(systemName: "music.note")
                .font(.system(size: 144))
                .foregroundColor(player.isPlaying ? .blue : .gray)
            
            Spacer()
            
            AudioPlayerControlView(player: player)
                .padding()
        }.onAppear{
            if let path = Bundle.main.path(forResource: "file_example_MP3_700KB", ofType: "mp3") {
                    let url = URL(fileURLWithPath: path)
                    player.prepareAndStartPlayingAudio(url: url)
                } else {
                    print("Audio file not found")
                }
        }
        .navigationTitle(songName)
    }
}
