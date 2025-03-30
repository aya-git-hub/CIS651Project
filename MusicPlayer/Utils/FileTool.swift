//
//  FileTool.swift
//  MusicPlayer
//
//  Created by yuao ai on 3/30/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import Foundation
class FileTool{
    static func copyDatabaseIfNeeded() {
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
                print("Database file not found in bundle.")
            }
        } else {
            print("Database already exists at \(destinationURL.path)")
        }
    }
    
    static func getFilesName() -> [String] {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
            let fileNames = fileURLs.map { $0.lastPathComponent }
            return fileNames
        } catch {
            print("Failed to read documents directory: \(error.localizedDescription)")
            return []
        }
    }
    
    static func getFile(_ file: String) -> URL {
        let fileManager = FileManager.default
        // 获取 Documents 目录的 URL
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Cannot access documents directory")
        }
        let fileURL = documentsURL.appendingPathComponent(file)
        return fileURL
    }
    
}
