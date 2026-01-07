import CryptoKit
import Foundation

actor ThumbnailCache {
    static let shared = ThumbnailCache()
    
    private var cache: [URL: CacheEntry] = [:]
    private let fileManager = FileManager.default
    private let cacheDirectory = URL.cachesDirectory.appendingPathComponent("Thumbnails")
    
    private init() {}
    
    // MARK: - Public API
    
    func imageURL(for space: Space) async throws -> URL {
        guard let thumbnailURL = space.previewThumbnailImage else {
            throw CacheError.noThumbnailURL
        }
        return try await imageURL(from: thumbnailURL)
    }
    
    func imageURL(from url: URL) async throws -> URL {
        let fileURL = cacheFileURL(for: url)
        
        // Check filesystem first (persistent cache)
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        
        // Check in-memory cache for in-progress or ready state
        if let entry = cache[url] {
            switch entry {
            case .ready(let cachedURL):
                return cachedURL
            case .inProgress(let task):
                return try await task.value
            }
        }
        
        // Start new download task
        let task = Task<URL, Error> {
            let (tempURL, _) = try await URLSession.shared.download(from: url)
            try ensureCacheDirectoryExists()
            try fileManager.moveItem(at: tempURL, to: fileURL)
            return fileURL
        }
        
        cache[url] = .inProgress(task)
        
        do {
            let resultURL = try await task.value
            cache[url] = .ready(resultURL)
            return resultURL
        } catch {
            cache[url] = nil
            throw error
        }
    }
    
    func cachedImageURL(for space: Space) -> URL? {
        guard let thumbnailURL = space.previewThumbnailImage else {
            return nil
        }
        let fileURL = cacheFileURL(for: thumbnailURL)
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    func removeImage(for space: Space) {
        guard let thumbnailURL = space.previewThumbnailImage else { return }
        let fileURL = cacheFileURL(for: thumbnailURL)
        cache[thumbnailURL] = nil
        try? fileManager.removeItem(at: fileURL)
    }
    
    func clearCache() {
        cache.removeAll()
        try? fileManager.removeItem(at: cacheDirectory)
    }
    
    // MARK: - Private
    
    private func cacheFileURL(for url: URL) -> URL {
        let hash = SHA256.hash(data: Data(url.absoluteString.utf8))
        let key = hash.compactMap { String(format: "%02x", $0) }.joined()
        return cacheDirectory.appendingPathComponent(key)
    }
    
    private func ensureCacheDirectoryExists() throws {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try fileManager.createDirectory(
                at: cacheDirectory,
                withIntermediateDirectories: true
            )
        }
    }
}

private enum CacheEntry {
    case inProgress(Task<URL, Error>)
    case ready(URL)
}
