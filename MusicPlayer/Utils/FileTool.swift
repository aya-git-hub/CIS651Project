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
    
    static func getBoxFilesName() -> [String] {
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
    
    static func getBoxFileURL(_ file: String) -> URL {
        let fileManager = FileManager.default
        // Get Sandbox Documents's URL
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Cannot access documents directory")
        }
        let fileURL = documentsURL.appendingPathComponent(file)
        return fileURL
    }
    
    static func getBundleFilesName() -> [String] {
        let fileManager = FileManager.default
        guard let resourcePath = Bundle.main.resourcePath else {
            return []
        }
        do {
            // 获取 resourcePath 下所有文件名
            let fileNames = try fileManager.contentsOfDirectory(atPath: resourcePath)
            return fileNames
        } catch {
            print("读取 Bundle 资源失败: \(error.localizedDescription)")
            return []
        }
    }
    
    static func getBundleFileURL(_ fileName: String) -> URL {
        // 拆分文件名与扩展名
        let components = fileName.split(separator: ".")
        guard !components.isEmpty else {
            fatalError("无效的文件名")
        }
        let name = String(components.first!)
        let ext = components.count > 1 ? String(components.last!) : nil
        guard let url = Bundle.main.url(forResource: name, withExtension: ext)
        else {
            fatalError("在 Bundle 中未找到文件：\(fileName)")
        }
        print("找到了")
        return url
    }
    
}
