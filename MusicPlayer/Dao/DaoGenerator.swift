//
//  DaoGenerator.swift
//  MusicPlayer
//
//  Created by yuao ai on 3/30/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import Foundation

class DaoGenerator{
    public func getMusicsDao() -> MusicsDao {
        var musicTable = MusicsDao("Musics")
        return musicTable
    }
}
