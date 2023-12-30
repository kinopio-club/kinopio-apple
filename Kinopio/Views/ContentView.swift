import SwiftUI
import StoreKit
import WebKit

struct ContentView: View {
    @State var isLoading = true
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
            
            WebViewWrapper(
                url: $url,
                isLoading: $isLoading,
                backgroundColor: $backgroundColor,
                isManageSubscriptionsSheetVisible: $isManageSubscriptionsSheetVisible,
                webController: webController
            )
            .ignoresSafeArea()
            .opacity(isLoading ? 0 : 1)
            .animation(.default.delay(0.5), value: isLoading)
            .sheet(isPresented: $showAddToInput) {
                AddToInboxView(onClose: onClose, webController: webController)
                    .presentationDetents([.height(240)])
            }
            .manageSubscriptionsSheet(isPresented: $isManageSubscriptionsSheetVisible)
            .onOpenURL(perform: onOpenURL)
            
            GeometryReader { geometry in
                Image("LogoBase")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: isLoading ? 64 : 36, height: isLoading ? 64 : 36)
                    .offset(
                        x: isLoading ? geometry.size.width / 2 - 64 / 2 : 8,
                        y: isLoading ? geometry.size.height / 2 - 64 / 2 : 6
                    )
                    .animation(.snappy.delay(0.2), value: isLoading)
                    .opacity(isLoading ? 1 : 0)
                    .animation(.default.delay(0.7), value: isLoading)
            }
            
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
