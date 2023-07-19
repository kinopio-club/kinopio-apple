import WebKit

extension WebViewWrapper {
    
    enum JSMethod: String, CaseIterable {
        case onLogout
        case setApiKey
        case createSubscription
        
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
        
        func execute(message: WKScriptMessage, webView: WKWebView) {
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
                case .createSubscription:
                    if let data = message.body as? [String: String],
                       let subscriptionId = data["appleSubscriptionId"],
                       let userId = data["userId"] {
                        
                        Task {
                            var isSuccess = false
                            
                            do {
                                guard let product = try await Store.shared.fetchProduct(identifier: subscriptionId) else {
                                    print("Couldn't find product with ID `\(subscriptionId)`")
                                    return
                                }
                                if try await Store.shared.purchase(product, userId: userId) != nil {
                                    isSuccess = true
                                }
                            } catch {
                                print(error)
                            }
                            
                            let javaScriptString = "window.postMessage({name: 'upgradedUser', isSuccess: \(isSuccess.description), userId: '\(userId)'})"
                            DispatchQueue.main.async {
                                webView.evaluateJavaScript(javaScriptString)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            webView.evaluateJavaScript("window.postMessage({name: 'upgradedUser', isSuccess: false})")
                        }
                        print("Invalid `message.body`!")
                        debugPrint(message.body)
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
