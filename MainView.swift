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
            VStack(spacing: 30) {
                NavigationLink(destination: ToneView()) {
                    Text("Go to Tone View")
                        .font(.title2)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
                NavigationLink(destination: RecordView()) {
                    Text("Go to Record View")
                        .font(.title2)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
                NavigationLink(destination:  DownloadPlayView()) {
                    Text("Go to Download View")
                        .font(.title2)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
                
                
                
            }
            .navigationTitle("Tones App")
        }
    }
}

// 预览
struct MainPreviews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
