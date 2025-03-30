//
//  LibraryDao.swift
//  MusicPlayer
//
//  Created by 王钊 on 3/30/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import Foundation

class LibraryDao: TablesDao {
    var DB: DatabaseManager
    var tableName: String
    
    init(_ name: String) {
        DB = DatabaseManager.getDBM()
        tableName = name
    }
    
    func getUserSongs(currentUserEmail: String) -> [String] {
        let condition = "Email = '\(currentUserEmail)'"
        let result = DB.queryRecords(tableName: self.tableName, condition: condition)
        print("Found \(result.count) songs for current user")
        
        // Return an array of music names only.
        let musicNames = result.compactMap { dict -> String? in
            return dict["MusicName"] as? String
        }
        return musicNames
    }
    
    func insertMusics(_ name: String, userEmail: String) {
        let record: [String: Any] = [
            "MusicName": name,
            "Email": userEmail
        ]
        DB.insertRecord(tableName: self.tableName, data: record)
        copyDatabaseBack()
    }
    
    func copyDatabaseBack() {
        let fileManager = FileManager.default
        
        guard let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Cannot find Documents' directory")
            return
        }
        
        let sourceURL = docsDir.appendingPathComponent("TheUserDatabase.sqlite")
        
        let destinationPath = "/Users/wangzhao/ProjectForMyself/CIS651Project/CIS651Project/database/TheUserDatabase.sqlite"
        let destinationURL = URL(fileURLWithPath: destinationPath)
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            print("Database has been copied to: \(destinationURL.path)")
        } catch {
            print("Copy database failed: \(error)")
        }
    }
}
