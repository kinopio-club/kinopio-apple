import WebKit

extension WKWebView {
    func loadURL(_ url: URL) {
        let request = URLRequest(url: url)
        load(request)
    }
}
