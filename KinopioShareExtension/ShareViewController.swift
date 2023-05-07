import UIKit
import SwiftUI
import UniformTypeIdentifiers
import WebKit


@objc(ShareExtensionViewController)
class ShareViewController: UIViewController {
    
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            var strings = [String]()
            
            guard let items = self.extensionContext?.inputItems as? [NSExtensionItem] else { return }
            
            for item in items {
                guard let attachments = item.attachments else { continue }
                
                strings = try await attachments.concurrentMap({ itemProvider in
                    
                    var type = UTType.plainText
                    
                    if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                        type = UTType.url
                    }
                    
                    let data = try? await itemProvider.loadItemAsync(forTypeIdentifier: type.identifier)
                    
                    if let url = data as? URL {
                        return url.absoluteString
                    } else if let data = data as? String {
                        return data.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    
                    return ""
                })
            }
            
            var text = ""
            
            for string in strings {
                text.append(string)
            }
            
            self.text = text
            
            // WebView
            
            let contentController = WKUserContentController()
            contentController.add(self, name: "onAdded")
            
            let config = WKWebViewConfiguration()
            config.userContentController = contentController
            
            let webView = WKWebView(frame: .zero, configuration: config)
            webView.navigationDelegate = self
            webView.underPageBackgroundColor = .white
            webView.backgroundColor = .white
            webView.allowsBackForwardNavigationGestures = false
            webView.layer.cornerRadius = 10
            webView.layer.masksToBounds = true
            
            webView.load(URLRequest(url: Configuration.webURL.appendingPathComponent("/add")))
            
            self.view = webView
            
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: view.superview!.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: view.superview!.bottomAnchor).isActive = true
            view.widthAnchor.constraint(equalTo: view.superview!.widthAnchor, multiplier: 1).isActive = true
            
        }
        
    }
    
}

extension ShareViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "onAdded" {
            extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
    
}

extension ShareViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let escapedText = text.replacingOccurrences(of: "'", with: "\'")
        let script = "window.postMessage('\(escapedText)', '*')"
        
        webView.evaluateJavaScript(script)
    }
    
}
