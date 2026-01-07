import Foundation
import AppIntents
import UIKit

@available(iOS 18.0, *)
struct OpenSpaceIntent: OpenIntent, URLRepresentableIntent {
    
    static var title: LocalizedStringResource = "Open Space"
    
    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$target)")
    }
    
    @Parameter(title: "Space")
    var target: SpaceEntity
    
}
