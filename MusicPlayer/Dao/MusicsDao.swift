//
//  MusicsDao.swift
//  MusicPlayer
//
//  Created by yuao ai on 3/28/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//
import Foundation
class musics{
    private var musicName:String=" ";
    private var index:Int = 0;
    private var author:String = " ";
    
}



//Use Factory pattern
class MusicsDao: TablesDao{
    var DB: DatabaseManager
    var tableName: String
     init(_ name: String){
         DB = DatabaseManager.getDBM()
        tableName = name
    }
    
    func getMusicsName() -> [String]{
        var result = DB.queryRecords(tableName: self.tableName,condition: "1=1")
        print(result.count)
        let musicNames = result.compactMap { $0["MusicName"] as? String }
        return musicNames
    }
    func insertMusics(_ name: String, _ author: String){
        let record: [String: Any] = ["MusicName": name, "Author": author]
        DB.insertRecord(tableName: self.tableName, data: record)
        copyDatabaseBack() 
    }
    func copyDatabaseBack() {
            let fileManager = FileManager.default
            
            guard let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Cannot find Documents' directory")
                return
            }
            
            // 假设数据库文件名为 "mydb.sqlite"（请根据实际情况修改）
            let sourceURL = docsDir.appendingPathComponent("TheUserDatabase.sqlite")
            
            // 目标路径，请修改为你希望保存数据库的原始位置
            let destinationPath = "/Users/yuao/Programs/Swifts/CISproject/Xylophone-iOS11/database/TheUserDatabase.sqlite"
            let destinationURL = URL(fileURLWithPath: destinationPath)
            
            do {
                // 如果目标文件已存在，则先删除
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.copyItem(at: sourceURL, to: destinationURL)
                print("Databasement has been copied to: \(destinationURL.path)")
            } catch {
                print("Copy database failed: \(error)")
            }
        }
    
}
