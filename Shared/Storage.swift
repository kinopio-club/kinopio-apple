import Foundation

enum Storage {
    
    static let userDefaults = UserDefaults.kinopio
    
    static func setToken(_ token: String) {
        userDefaults.set(token, forKey: "token")
    }
    
    static func getToken() -> String? {
        userDefaults.string(forKey: "token")
    }
    
    static func reset() {
        userDefaults.removeObject(forKey: "token")
    }
    
}
