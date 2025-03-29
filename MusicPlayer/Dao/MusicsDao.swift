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

class MusicsDaoGenrator{
    public func getMusicsDao() -> MusicsDao {
        var musicTable = MusicsDao("Musics")
        return musicTable
    }
}

//Use Factory pattern
class MusicsDao: TablesDao{
    var DB: DatabaseManager
    var tableName: String
     init(_ name: String){
        DB = DatabaseManager()
        tableName = name
    }
    
    func getMusicsName() -> [String]{
        var result = DB.queryRecords(tableName: self.tableName,condition: "1=1")
        print(result.count)
        let musicNames = result.compactMap { $0["MusicName"] as? String }
        return musicNames
    }
    
}
