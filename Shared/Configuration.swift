import Foundation

struct Configuration {
    static let apiHost = "api.kinopio.club"
    static let host = "kinopio.club"
    
    static let apiURL = URL(string: "https://\(apiHost)")!
    static let hostURL = URL(string: "https://\(host)")!
    static let appURL = hostURL.appendingPathComponent("app")
    static let addURL = hostURL.appendingPathComponent("add")
}
