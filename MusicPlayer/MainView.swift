//
//  MainView.swift
//  Xylophone
//
//  Created by yuao ai on 2/23/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//
import SwiftUI;

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer() // 让按钮固定在底部
                
                HStack(spacing: 50) {
                    NavigationLink(destination: ToneView()) {
                        VStack {
                            Image(systemName: "music.note")
                                .font(.system(size: 28))
                            Text("Tone")
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
                    
                    NavigationLink(destination: DownloadPlayView()) {
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
                .background(Color.gray.opacity(0.2)) // 设置底部背景颜色
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            .ignoresSafeArea(edges: .bottom) // 让底部栏贴合屏幕底部
        }
    }
}

// 预览
struct MainPreviews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
