import Foundation

public extension URL {
    
    var isKinopio: Bool {
        host == Configuration.host
    }
    
}
