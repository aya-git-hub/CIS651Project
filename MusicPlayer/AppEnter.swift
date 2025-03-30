//
//  AppEnter.swift
//  MusicPlayer
//
//  Created by yuao ai on 2/23/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import SwiftUI

@main
struct MusicApp: App {
    init(){
        for fileURL in FileTool.getFilesName(){
                    print(fileURL)
                }
        FileTool.copyDatabaseIfNeeded()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

