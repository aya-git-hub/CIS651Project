import Foundation

class MusicCache {
    static let shared = MusicCache()
    private var cache: [String: URL] = [:]
    private let queue = DispatchQueue(label: "com.musicplayer.cache", attributes: .concurrent)
    
    private init() {}
    
    func getURL(for musicName: String) -> URL? {
        var result: URL?
        queue.sync {
            result = cache[musicName]
        }
        return result
    }
    
    func setURL(_ url: URL, for musicName: String) {
        queue.async(flags: .barrier) {
            self.cache[musicName] = url
        }
    }
    
    func removeURL(for musicName: String) {
        queue.async(flags: .barrier) {
            self.cache.removeValue(forKey: musicName)
        }
    }
    
    func clear() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
} 