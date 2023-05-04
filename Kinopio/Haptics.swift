import SwiftUI

enum Haptics {
    
    @AppStorage("haptics", store: .kinopio) static var isHapticsEnabled = true
    
    static func selectionChanged() {
        if isHapticsEnabled {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    static func impactOccurred(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        if isHapticsEnabled {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
    
    static func notificationOccurred(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        if isHapticsEnabled {
            UINotificationFeedbackGenerator().notificationOccurred(type)
        }
    }
    
}
