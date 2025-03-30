//
//  TablesDao.swift
//  MusicPlayer
//
//  Created by yuao ai on 3/28/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import Foundation
protocol TablesDao{
    var tableName:String { get set }
    var DB:DatabaseManager { get set}
    func copyDatabaseBack()
}
