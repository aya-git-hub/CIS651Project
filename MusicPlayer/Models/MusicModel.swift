import Foundation
import FirebaseFirestore

struct MusicRecord {
    var userEmail: String
    var musicName: String
    var filePath: String
    var downloadDate: Timestamp
    var size: Int64
    var contentType: String
    var isFavorite: Bool?
    var localPath: String?

    // Dictionary initializer
    init?(dictionary: [String: Any]) {
        guard let userEmail = dictionary["userEmail"] as? String,
              let musicName = dictionary["musicName"] as? String,
              let filePath = dictionary["filePath"] as? String,
              let downloadDate = dictionary["downloadDate"] as? Timestamp,
              let size = dictionary["size"] as? Int64,
              let contentType = dictionary["contentType"] as? String else {
            return nil
        }
        self.userEmail = userEmail
        self.musicName = musicName
        self.filePath = filePath
        self.downloadDate = downloadDate
        self.size = size
        self.contentType = contentType
        self.isFavorite = dictionary["isFavorite"] as? Bool
        self.localPath = dictionary["localPath"] as? String
    }

    // Parameter constructor - Adding this will prevent errors
    init(userEmail: String, musicName: String, filePath: String, downloadDate: Timestamp, size: Int64, contentType: String, isFavorite: Bool? = nil, localPath: String? = nil) {
        self.userEmail = userEmail
        self.musicName = musicName
        self.filePath = filePath
        self.downloadDate = downloadDate
        self.size = size
        self.contentType = contentType
        self.isFavorite = isFavorite
        self.localPath = localPath
    }

    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "userEmail": userEmail,
            "musicName": musicName,
            "filePath": filePath,
            "downloadDate": downloadDate,
            "size": size,
            "contentType": contentType
        ]
        if let isFavorite = isFavorite {
            dict["isFavorite"] = isFavorite
        }
        if let localPath = localPath {
            dict["localPath"] = localPath
        }
        return dict
    }
}
