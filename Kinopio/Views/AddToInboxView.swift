import SwiftUI
import WebKit

struct AddToInboxView: UIViewRepresentable {
    
    var onClose: ((URL?) -> Void)?
    var webController: WebViewController
    
    func makeUIView(context: Context) -> WKWebView  {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "addCardFromAddPage")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.underPageBackgroundColor = .white
        webView.backgroundColor = .white
        webView.allowsBackForwardNavigationGestures = false
        webView.layer.cornerRadius = 10
        webView.layer.masksToBounds = true
        
#if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
        
        let request = URLRequest(url: Configuration.webURL.appendingPathComponent("add"))
        webView.load(request)
        
        return webView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onClose: onClose, webController: webController)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.onClose = onClose
        context.coordinator.webController = webController
    }
    
    class Coordinator: NSObject {
        var onClose: ((URL?) -> Void)?
        var webController: WebViewController
        
        init(onClose: ((URL?) -> Void)? = nil, webController: WebViewController) {
            self.onClose = onClose
            self.webController = webController
        }
    }
    
}

extension AddToInboxView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "addCardFromAddPage" {
            webController.triggerPostMessage(name: "addedCardFromAddPage", body: message.body)
        }
    }
}

extension AddToInboxView.Coordinator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
            onClose?(url)
            return .cancel
        }
        
        return .allow
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AddToInboxView(webController: WebViewController())
    }
}
