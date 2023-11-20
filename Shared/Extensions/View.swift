import SwiftUI
import WidgetKit

extension View {
    
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
    
}
