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
        if color.hasPrefix("#") {
            return Color(hex: color)
        } else if color.hasPrefix("rgb(") {
            return Color(rgb: color)
        } else {
            return .accentColor
        }
    }
}
