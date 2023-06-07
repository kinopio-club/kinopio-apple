import Foundation

extension Networking {
    
    struct APIResponse: Codable {
        var message: String
        
        static func parseFromData(_ data: Data) -> Self? {
            try? JSONDecoder().decode(Self.self, from: data)
        }
    }
    
}
