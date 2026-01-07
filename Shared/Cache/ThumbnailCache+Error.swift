import Foundation

extension ThumbnailCache {
    enum CacheError: Error, LocalizedError {
        case noThumbnailURL
        case downloadFailed

        var errorDescription: String? {
            switch self {
            case .noThumbnailURL:
                "Space has no thumbnail URL."
            case .downloadFailed:
                "Failed to download thumbnail image."
            }
        }
    }
}
