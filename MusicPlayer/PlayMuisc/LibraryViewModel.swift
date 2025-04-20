//
//  LibraryViewModel.swift
//  MusicPlayer
//
//  Created by 王钊 on 3/30/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import AVKit
import Foundation


// ViewModel: 从数据库中加载当前用户的歌曲名称
class LibraryViewModel: ObservableObject {
    @Published var songs: [String] = []
    private var libraryDao: LibraryDao
    
    // 初始化时传入当前用户的邮箱
    init() {
        libraryDao = LibraryDao("Library")
    }
    
    // 加载数据库中的歌曲，过滤条件为当前用户
    func loadSongs() {
        self.songs = libraryDao.getUserSongs(currentUserEmail: "132@qq.com")
    }
}
