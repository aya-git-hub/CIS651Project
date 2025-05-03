//  MainView.swift
//  Xylophone
//
//  Created by yuao ai on 2/23/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//
import SwiftUI;

struct MainView: View {
    @EnvironmentObject var mediaPlayerState: MediaPlayerState
    @ObservedObject var viewModel: PlayerTestViewModel
    var authViewModel = AuthViewModel.getAuth()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer() // Fix buttons at the bottom
                
                // Add custom album cover image
                Image("album_cover") // This should be the name of your image in Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                               
                Spacer()
                
                // Mini player
                if viewModel.currentMusicIndex >= 0 {
                    MiniPlayerView(viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                }
                
                HStack(spacing: 50) {
                    NavigationLink(destination: HomeView().environmentObject(mediaPlayerState)
                    
                    
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }) {
                        VStack {
                            Image(systemName: "music.note")
                                .font(.system(size: 28))
                            Text("Tone")
                                .font(.caption)
                        }
                        .padding()
                    }
                    NavigationLink(destination: PlayerTestView(viewModel: viewModel)) {
                        VStack {
                            Image(systemName: "music.note")
                                .font(.system(size: 28))
                            Text("Play")
                                .font(.caption)
                        }
                        .padding()
                    }
                    
                    
                    NavigationLink(destination: RecordView()) {
                        VStack {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 28))
                            Text("Record")
                                .font(.caption)
                        }
                        .padding()
                    }
                    
                    NavigationLink(destination: DownloadPlayView(playerViewModel: viewModel)) {
                        VStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 28))
                            Text("Download")
                                .font(.caption)
                        }
                        .padding()
                    }
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2)) // Set bottom background color
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            .ignoresSafeArea(edges: .bottom) // Make bottom bar fit screen bottom
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileMenuView()
                        .environmentObject(authViewModel)
                }
            }
        }

    }
}
