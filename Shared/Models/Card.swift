import Foundation

struct Card: Identifiable, Codable {
    var id: String
    var name: String
    var spaceId: String
    var x: Int?
    var y: Int?
    var z: Int?
}
