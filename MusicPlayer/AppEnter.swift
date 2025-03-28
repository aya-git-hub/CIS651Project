//
//  AppEnter.swift
//  MusicPlayer
//
//  Created by yuao ai on 2/23/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import SwiftUI
func copyDatabaseIfNeeded() {
    let fileManager = FileManager.default

    let documentsURL = try! fileManager.url(for: .documentDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: false)

    let destinationURL = documentsURL.appendingPathComponent("TheUserDatabase.sqlite")

    if !fileManager.fileExists(atPath: destinationURL.path) {
        if let bundleURL = Bundle.main.url(forResource: "TheUserDatabase", withExtension: "sqlite") {
            do {
                try fileManager.copyItem(at: bundleURL, to: destinationURL)
                print("✅ Copied database to \(destinationURL.path)")
            } catch {
                print("❌ Failed to copy database: \(error)")
            }
        } else {
            print("❌ Database file not found in bundle.")
        }
    } else {
        print("📁 Database already exists at \(destinationURL.path)")
    }
}
@main
struct MusicApp: App {
    init(){
        copyDatabaseIfNeeded()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

