//
//  FirebaseMusicManager.swift
//  MusicPlayer
//
//  Created by Pengfei Liu on 4/22/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI


class FirebaseMusicManager {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    static let shared = FirebaseMusicManager()
    private init() {}

    // 存储音乐记录
    func storeUserMusicData(record: MusicRecord, completion: @escaping (Bool) -> Void) {
        db.collection("user_musics")
            .addDocument(data: record.dictionary) { error in
                if let error = error {
                    print("❌ Error storing music data: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
    }

    // 获取当前用户音乐记录
    func getUserMusics(completion: @escaping ([MusicRecord]) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion([])
            return
        }

        db.collection("user_musics")
            .whereField("userEmail", isEqualTo: user.email ?? "")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error getting user musics: \(error)")
                    completion([])
                    return
                }

                let musics = snapshot?.documents.compactMap { doc -> MusicRecord? in
                    return MusicRecord(dictionary: doc.data())
                } ?? []
                completion(musics)
            }
    }

    // 删除指定音乐
    func deleteUserMusic(musicName: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }

        db.collection("user_musics")
            .whereField("userEmail", isEqualTo: user.email ?? "")
            .whereField("musicName", isEqualTo: musicName)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error finding music to delete: \(error)")
                    completion(false)
                    return
                }

                let batch = self.db.batch()
                snapshot?.documents.forEach { doc in
                    batch.deleteDocument(doc.reference)
                }

                batch.commit { error in
                    if let error = error {
                        print("❌ Error deleting music data: \(error)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
    }
    
    //update(标记收藏/取消收藏, 修改本地路径或文件名, 更新播放统计、标签)
    func updateUserMusic(musicName: String, updates: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }

        db.collection("user_musics")
            .whereField("userEmail", isEqualTo: user.email ?? "")
            .whereField("musicName", isEqualTo: musicName)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ 查找待更新音乐失败: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let doc = snapshot?.documents.first else {
                    print("❌ 未找到音乐记录")
                    completion(false)
                    return
                }

                doc.reference.updateData(updates) { error in
                    if let error = error {
                        print("❌ 更新失败: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("✅ 更新成功: \(musicName)")
                        completion(true)
                    }
                }
            }
    }
    
}
