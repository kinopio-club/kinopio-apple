import SwiftUI
import WebKit

struct AddToInboxView: UIViewRepresentable {
    var onClose: ((URL?) -> Void)?
    
    func makeUIView(context: Context) -> WKWebView  {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "onAdded")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.underPageBackgroundColor = .white
        webView.backgroundColor = .white
        webView.allowsBackForwardNavigationGestures = false
        webView.layer.cornerRadius = 10
        webView.layer.masksToBounds = true
        
        let request = URLRequest(url: Configuration.webURL.appendingPathComponent("add"))
        webView.load(request)
        
        return webView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onClose: onClose)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.onClose = onClose
    }
    
    class Coordinator: NSObject {
        var onClose: ((URL?) -> Void)?
        
        init(onClose: ((URL?) -> Void)? = nil) {
            self.onClose = onClose
        }
    }
    
}

extension AddToInboxView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "onAdded" {
            onClose?(nil)
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
        AddToInboxView()
    }
}
