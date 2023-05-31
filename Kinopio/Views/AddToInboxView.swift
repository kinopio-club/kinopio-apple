import SwiftUI
import WebKit

struct AddToInboxView: UIViewRepresentable {
    var onAdded: (() -> Void)?
    
    func makeUIView(context: Context) -> WKWebView  {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "onAdded")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
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
        return Coordinator(onAdded: onAdded)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.onAdded = onAdded
    }
    
    class Coordinator: NSObject {
        var onAdded: (() -> Void)?
        
        init(onAdded: (() -> Void)? = nil) {
            self.onAdded = onAdded
        }
    }
    
}

extension AddToInboxView.Coordinator: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "onAdded" {
           onAdded?()
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AddToInboxView()
    }
}
