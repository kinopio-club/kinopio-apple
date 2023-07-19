import Foundation
import WebKit
import SwiftUI

struct WebViewWrapper: UIViewRepresentable {
    @Binding var url: URL
    @Binding var isLoading: Bool
    @Binding var backgroundColor: Color
    
    func makeUIView(context: Context) -> WKWebView  {
        guard let scriptPath = Bundle.main.path(forResource: "web", ofType: "js"),
              let scriptSource = try? String(contentsOfFile: scriptPath) else {
            fatalError("Couldn't load web.js")
        }
        
        // JS CONFIG
        let contentController = WKUserContentController()
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(script)
        contentController.add(context.coordinator, name: "onLoad")
        contentController.add(context.coordinator, name: "setBackgroundColor")
        for method in JSMethod.allCases {
            contentController.add(context.coordinator, name: method.name)
        }
        
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        config.limitsNavigationsToAppBoundDomains = true
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.underPageBackgroundColor = .clear
        webView.backgroundColor = .clear
        webView.allowsBackForwardNavigationGestures = false
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
#if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
        
        context.coordinator.urlChangedObservation = webView.observe(\.url, options: .new) { view, change in
            if let url = view.url {
                self.url = url
            }
        }
        
        // Request
        webView.loadURL(url)
        
        context.coordinator.webView = webView
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url?.absoluteString != url.absoluteString {
            webView.loadURL(url)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(url: $url, isLoading: $isLoading, backgroundColor: $backgroundColor)
    }
    
    class Coordinator: NSObject {
        @Binding var url: URL
        @Binding var isLoading: Bool
        @Binding var backgroundColor: Color
        
        var webView: WKWebView?
        
        let downloadDelegate = DownloadDelegate()
        var urlChangedObservation: NSKeyValueObservation?
        
        init(url: Binding<URL>, isLoading: Binding<Bool>, backgroundColor: Binding<Color>) {
            _url = url
            _isLoading = isLoading
            _backgroundColor = backgroundColor
            
            super.init()
        }
    }
}

extension WebViewWrapper.Coordinator: WKNavigationDelegate {
    private func shouldOpenInWindow(_ host: String) -> Bool {
        host == Configuration.host
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        if let url = navigationAction.request.url,
           let host = url.host,
           !shouldOpenInWindow(host) && navigationAction.targetFrame?.isMainFrame != false {
            await UIApplication.shared.open(url)
            
            return .cancel
        }
        else if let url = navigationAction.request.url,
                navigationAction.shouldPerformDownload || url.lastPathComponent.contains("download"),
                let _ = navigationAction.request.url {
            return .download
        }
        else if let url = navigationAction.request.url,
                navigationAction.navigationType == .linkActivated {
            await webView.loadURL(url)
            return .cancel
        }
        // iframes
        else if navigationAction.targetFrame?.isMainFrame == false {
            return .allow
        }
        else {
            return .allow
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        if navigationResponse.canShowMIMEType {
            return .allow
        }
        else if let _ = navigationResponse.response.url {
            return .download
        } else {
            return .cancel
        }
    }
    
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = downloadDelegate
    }
    
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = downloadDelegate
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url {
            self.url = url
        }
        isLoading = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let idiom = UIDevice.current.userInterfaceIdiom
        
        let devicesWithNeedForSafeAreaPaddingBottom: [UIUserInterfaceIdiom] = [.pad, .phone]
        let shouldAddSafeAreaPaddingBottom = devicesWithNeedForSafeAreaPaddingBottom.contains(idiom)
        
        let devicesWithNeedForSafeAreaPaddingTop: [UIUserInterfaceIdiom] = []
        let shouldAddSafeAreaPaddingTop = devicesWithNeedForSafeAreaPaddingTop.contains(idiom)
        
        let script = """
navigator.shouldAddSafeAreaPaddingTop = \(shouldAddSafeAreaPaddingTop.description)
navigator.shouldAddSafeAreaPaddingBottom = \(shouldAddSafeAreaPaddingBottom)
"""
        webView.evaluateJavaScript(script)
    }
    
}

extension WebViewWrapper.Coordinator: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let frame = navigationAction.targetFrame,
           frame.isMainFrame {
            return nil
        }
        webView.load(navigationAction.request)
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let preferredStyle = UIDevice.current.userInterfaceIdiom == .pad ? UIAlertController.Style.alert : UIAlertController.Style.actionSheet
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: preferredStyle)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            completionHandler(false)
        }))
        
        if let vc = webView.window?.rootViewController {
            vc.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alertController.addTextField()
        
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
            let input = alertController.textFields?.first
            completionHandler(input?.text)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            completionHandler(nil)
        }))
        
        if let vc = webView.window?.rootViewController {
            vc.present(alertController, animated: true, completion: nil)
        }
    }
}

extension WebViewWrapper.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let method = WebViewWrapper.JSMethod(rawValue: message.name) {
            method.execute(message: message, webView: webView!)
        }
        else if message.name == "onLoad" {
            // Replaces the didFinish method from WKNavigationDelegate to prevent white flashes during loading.
            // Requires an injected JS file that calls `window.webkit.messageHandlers.onLoad.postMessage('')`
            isLoading = false
        }
        else if message.name == "setBackgroundColor", let color = message.body as? String {
            backgroundColor = Color.parseWebColor(color) ?? Color(uiColor: .systemBackground)
        }
        else {
            print("Unkown JSMethod: \(message.name)")
        }
    }
}

// MARK: Downloads
extension WebViewWrapper.Coordinator {
    class DownloadDelegate: NSObject, WKDownloadDelegate {
        
        private var filePathDestination: URL?
        
        func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
            
            let url = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(suggestedFilename)
            filePathDestination = url
            
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    print("Not able to removeItem at \(url.absoluteString)")
                    print(error)
                }
            }
            
            completionHandler(url)
        }
        
        func downloadDidFinish(_ download: WKDownload) {
            if let url = filePathDestination {
                DispatchQueue.main.async {
                    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    if let webView = download.webView, let controller = webView.window?.rootViewController {
                        controller.present(activityVC, animated: true, completion: nil)
                    }
                }
            }
        }
        
        func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
            print("Download failed:")
            print(error)
            print(error.localizedDescription)
        }
        
    }
}
