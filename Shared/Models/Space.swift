import Foundation

struct Space: Identifiable, Codable {
    var id: String
    var cards: [Card]?
    var name: String
    var privacy: String
    var createdAt: Date
    var editedAt: Date?
    var previewThumbnailImage: URL?
}

extension Collection where Element == Space {
    
    var sortedByLastEditedAt: [Element] {
        self.sorted { a, b in
            let aDate = a.editedAt ?? a.createdAt
            let bDate = b.editedAt ?? b.createdAt
            return aDate.compare(bDate) == .orderedDescending
        }
    }
    
}
