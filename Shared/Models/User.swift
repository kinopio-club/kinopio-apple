import Foundation
import SwiftUI

struct User: Identifiable, Codable {
    var id: String
    var apiKey: UUID
    var color: String = "#63D2D1" // Accent Color
    var email: String
    var name: String
}

extension User {
    var nativeColor: Color {
        Color.parseWebColor(color) ?? .accentColor
    }
}
