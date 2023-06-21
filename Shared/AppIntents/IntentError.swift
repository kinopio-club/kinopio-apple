import Foundation

enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case notAuthenticated, unknown(message: String?)
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .notAuthenticated:
            return "You are not authenticated. Please open the Kinopio app and login."
        case .unknown(let message):
            if let message {
                return "Action could not be completed: \(message)"
            }
            else {
                return "Action could not be completed for an unknown reason."
            }
        }
    }
}
