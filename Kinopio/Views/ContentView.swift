import SwiftUI
import StoreKit
import WebKit

struct ContentView: View {
    @State var isLoading = false
    @SceneStorage("url") var url = Configuration.webURL
    @SceneStorage("backgroundColor") var backgroundColor = Color.white
    @State private var showAddToInput = false
    @State private var isManageSubscriptionsSheetVisible = false
    
    var webController = WebViewController()
    
    private func onOpenURL(_ url: URL) {
        if url.path == ("/add") {
            showAddToInput = true
        } else {
            self.url = url
        }
    }
    
    private func onClose(_ url: URL?) {
        showAddToInput.toggle()
        if let url {
            onOpenURL(url)
        }
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea(.all)
            
            if isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(.bottom)
                }
                .transition(.opacity.animation(.default))
            }
            
            WebViewWrapper(
                url: $url,
                isLoading: $isLoading,
                backgroundColor: $backgroundColor,
                isManageSubscriptionsSheetVisible: $isManageSubscriptionsSheetVisible,
                webController: webController
            )
            .ignoresSafeArea()
            .opacity(isLoading ? 0 : 1)
            .animation(.default, value: isLoading)
            .sheet(isPresented: $showAddToInput) {
                AddToInboxView(onClose: onClose, webController: webController)
                    .presentationDetents([.height(240)])
            }
            .manageSubscriptionsSheet(isPresented: $isManageSubscriptionsSheetVisible)
            .onOpenURL(perform: onOpenURL)
        }
    }
    
}

class WebViewController {
    
    weak var webView: WKWebView?
    
    func triggerPostMessage(name: String, body: Any) {
        let payload = ["name": name, "value": body]
        
        let data = try? JSONSerialization.data(withJSONObject: payload, options: [.fragmentsAllowed, .prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        if let data, let body = String(data: data, encoding: .utf8) {
            let script = "window.postMessage(\(body), '*')"
            webView?.evaluateJavaScript(script)
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
