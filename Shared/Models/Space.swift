import Foundation

struct Space: Identifiable, Codable {
    var id: String
    var cards: [Card]?
    var name: String
    var privacy: String
    var createdAt: Date
    var editedAt: Date?
}
