import Foundation

enum Storage {
    
    static let userDefaults = UserDefaults.kinopio
    
    static func setToken(_ token: String) {
        userDefaults.set(token, forKey: "token")
    }
    
    static func getToken() -> String? {
        userDefaults.string(forKey: "token")
    }
    
    static func setUserColor(_ color: String) {
        userDefaults.set(color, forKey: "userColor")
    }
    
    static func getUserColor() -> String? {
        userDefaults.string(forKey: "userColor")
    }
    
    static func setNumberOfCards(_ numberOfCards: Int) {
        userDefaults.setValue(numberOfCards, forKey: "numberOfCards")
    }
    
    static func getNumberOfCards() -> Int? {
        userDefaults.integer(forKey: "numberOfCards")
    }
    
    static func reset() {
        userDefaults.removeObject(forKey: "token")
        userDefaults.removeObject(forKey: "userColor")
        userDefaults.removeObject(forKey: "numberOfCards")
    }
    
}
