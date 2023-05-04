import WebKit

extension WebViewWrapper {
    
    enum JSMethod: String, CaseIterable {
        case onLogout
        case setApiKey
        
        // UISelectionFeedbackGenerator
        case onSelectionFeedback
        
        // UIImpactFeedbackGenerator
        case onRigidImpactFeedback
        case onSoftImpactFeedback
        case onLightImpactFeedback
        case onMediumImpactFeedback
        case onHeavyImpactFeedback
        
        // UINotificationFeedbackGenerator
        case onSuccessFeedback
        case onWarningFeedback
        case onErrorFeedback
        
        var name: String { self.rawValue }
        
        func execute(message: WKScriptMessage) {
            switch self {
                case .onLogout:
                    // Clear all website data
                    WKWebsiteDataStore.default().removeData(
                        ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                        modifiedSince: Date(timeIntervalSince1970: 0),
                        completionHandler: {}
                    )
                    
                    Storage.reset()
                case .setApiKey:
                    if let token = message.body as? String {
                        Storage.setToken(token)
                    }
                case .onSelectionFeedback:
                    Haptics.selectionChanged()
                case .onRigidImpactFeedback:
                    Haptics.impactOccurred(.rigid)
                case .onSoftImpactFeedback:
                    Haptics.impactOccurred(.soft)
                case .onLightImpactFeedback:
                    Haptics.impactOccurred(.light)
                case .onMediumImpactFeedback:
                    Haptics.impactOccurred(.medium)
                case .onHeavyImpactFeedback:
                    Haptics.impactOccurred(.heavy)
                case .onSuccessFeedback:
                    Haptics.notificationOccurred(.success)
                case .onErrorFeedback:
                    Haptics.notificationOccurred(.error)
                case .onWarningFeedback:
                    Haptics.notificationOccurred(.warning)
            }
        }
    }
    
}
