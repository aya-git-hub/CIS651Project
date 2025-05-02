//
//  SearchBar.swift
//  MusicPlayer
//
//  Created by yuao ai on 4/23/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//
import SwiftUI
import Foundation
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
/*
 //import SwiftUI
 //import AVKit
 //import LLM
 //
 //struct DownloadPlayView: View {
 //    @StateObject private var viewModel = DownloadPlayViewModel.getDownloadPlay()
 //    @State private var searchText: String = ""
 //    @State private var showDeleteAlert: Bool = false
 //    @State private var selectedMusicForDelete: String? = nil
 //    @State private var showAlert: Bool = false
 //    @State private var alertMessage: String = ""
 //    @State private var showChatView: Bool = false
 //    var authViewModel = AuthViewModel.getAuth();
 //    @State private var navigateToLogin = false
 //
 //    // 根据搜索文本过滤音乐名称
 //    var filteredMusicNames: [String] {
 //        if searchText.isEmpty {
 //            return viewModel.availableMusicItems
 //        } else {
 //            return viewModel.availableMusicItems.filter {
 //                $0.lowercased().contains(searchText.lowercased())
 //            }
 //        }
 //    }
 //
 //    var body: some View {
 //        NavigationView {
 //            ZStack {
 //                VStack(spacing: 0) {
 //                    // 搜索栏
 //                    SearchBar(text: $searchText)
 //                        .padding(.horizontal)
 //                        .padding(.top, 8)
 //
 //                    // 可下载的音乐列表
 //                    List {
 //                        Section(header: Text("Downloadable Music")) {
 //                            ForEach(filteredMusicNames, id: \.self) { music in
 //                                MusicRow(
 //                                    musicName: music,
 //                                    isDownloaded: viewModel.downloadedItems.contains(music),
 //                                    isPlaying: viewModel.currentPlayingMusic == music,
 //                                    downloadAction: {
 //                                        if !viewModel.downloadedItems.contains(music) {
 //                                            viewModel.downloadWithMetadata(for: music)
 //                                        }
 //                                    },
 //                                    playAction: {
 //                                        playMusic(music)
 //                                    }
 //                                )
 //                            }
 //                        }
 //                    }
 //                    .listStyle(PlainListStyle())
 //
 //                    // 已下载的音乐列表
 //                    if !viewModel.downloadedItems.isEmpty {
 //                        VStack(alignment: .leading, spacing: 0) {
 //                            Text("Downloaded Music")
 //                                .font(.headline)
 //                                .padding(.horizontal)
 //                                .padding(.top, 8)
 //
 //                            List {
 //                                ForEach(viewModel.downloadedItems, id: \.self) { music in
 //                                    DownloadedMusicRow(
 //                                        musicName: music,
 //                                        isPlaying: viewModel.currentPlayingMusic == music,
 //                                        deleteAction: {
 //                                            viewModel.deleteMusicEverywhere(music)
 //                                        }
 //                                    )
 //                                }
 //                            }
 //                            .listStyle(PlainListStyle())
 //                        }
 //                        .frame(height: 200)
 //                    }
 //
 //                    // 播放器控制区域
 //                    if let player = viewModel.player {
 //                        PlayerControlView(player: player)
 //                            .padding()
 //                            .background(Color(UIColor.systemGray6))
 //                    }
 //                }
 //                Button("🚪 退出登录") {
 //                                authViewModel.signOut()
 //                                navigateToLogin = true
 //                            }
 //                            .buttonStyle(.bordered)
 //                            .foregroundColor(.red)
 //                            .padding(.top, 30)
 //                // 悬浮聊天按钮
 //                VStack {
 //                    Spacer()
 //                    HStack {
 //                        Spacer()
 //                        Button(action: {
 //                            showChatView = true
 //                        }) {
 //                            Image(systemName: "message.circle.fill")
 //                                .font(.system(size: 50))
 //                                .foregroundColor(.blue)
 //                                .shadow(radius: 3)
 //                        }
 //                        .padding(.trailing, 20)
 //                        .padding(.bottom, 20)
 //                    }
 //                }
 //            }
 //            .navigationTitle("Search Your Music")
 //            .alert(isPresented: $showAlert) {
 //                Alert(
 //                    title: Text("提示"),
 //                    message: Text(alertMessage),
 //                    dismissButton: .default(Text("确定"))
 //                )
 //            }
 //        }
 //        .sheet(isPresented: $showChatView) {
 //            AiChatView()
 //        }
 //
 //    }
 //
 //    private func playMusic(_ musicName: String) {
 //        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
 //        let musicURL = documentsDirectory.appendingPathComponent(musicName)
 //
 //        if FileManager.default.fileExists(atPath: musicURL.path) {
 //            viewModel.playMusic(musicName)
 //        } else {
 //            alertMessage = "音乐文件不存在，请先下载"
 //            showAlert = true
 //        }
 //    }
 //}
 //
 //// 搜索栏组件
 //
 //
 //
 //// 已下载音乐行组件
 //
 //// 播放器控制组件
 //
 //struct DownloadPlayView_Previews: PreviewProvider {
 //    static var previews: some View {
 //        DownloadPlayView()
 //    }
 //}
 //
 */
