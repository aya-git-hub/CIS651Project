//
//  AppEnter.swift
//  MusicPlayer
//
//  Created by yuao ai on 2/23/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import SwiftUI
import AVKit
@main
struct MusicApp: App {
    init(){
        for fileURL in FileTool.getBundleFilesName(){
                    print(fileURL)
                }
        if let url = FileTool.getBundleFileURL("story.mp3") {
            let player = AVPlayer(url: url)
            player.play()
        } else {
            print("Can not find file")
        }
        FileTool.copyDatabaseIfNeeded()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

