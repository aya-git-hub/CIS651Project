//
//  SyncManager.swift
//  MusicPlayer
//
//  Created by Pengfei Liu on 4/22/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SyncManager {
    static let shared = SyncManager()

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}

    /// 同步 Firestore 下载记录到本地
    func syncDownloadedMusicIfNeeded(viewModel: DownloadPlayViewModel) {
        guard let user = Auth.auth().currentUser else {
            print("⚠️ 当前用户未登录，无法同步音乐记录")
            return
        }
        
        db.collection("user_musics")
            .whereField("userEmail", isEqualTo: user.email ?? "")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ 获取 Firestore 下载记录失败：\(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("ℹ️ 没有找到任何下载记录")
                    return
                }
                
                let fileManager = FileManager.default
                let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                
                for doc in documents {
                    let data = doc.data()
                    guard let musicName = data["musicName"] as? String else { continue }
                    
                    let localURL = docsURL.appendingPathComponent(musicName)
                    
                    if !fileManager.fileExists(atPath: localURL.path) {
                        // ⬇️ 本地不存在，触发下载
                        print("⬇️ 同步缺失音乐：\(musicName)")
                        
                        let storageRef = self.storage.reference().child("music/\(musicName)")
                        storageRef.write(toFile: localURL) { url, error in
                            DispatchQueue.main.async {
                                if let error = error {
                                    print("❌ 下载 \(musicName) 失败：\(error.localizedDescription)")
                                } else {
                                    print("✅ 同步完成：\(musicName)")
                                    if !viewModel.downloadedItems.contains(musicName) {
                                        viewModel.downloadedItems.append(musicName)
                                    }
                                }
                            }
                        }
                    } else {
                        // ✅ 本地已存在
                        DispatchQueue.main.async {
                            if !viewModel.downloadedItems.contains(musicName) {
                                viewModel.downloadedItems.append(musicName)
                            }
                            print("✅ 本地已存在：\(musicName)")
                            
                        }
                    }
                }
            }
        viewModel.loadDownloadedMusic()
    }
}
