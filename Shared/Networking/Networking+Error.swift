import Foundation

extension Networking {
    
    enum APIError: Error, LocalizedError {
        case badRequest(message: String = "An unknown error occurred.") // 400
        case unauthorized(message: String = "You are not authenticated.") // 401
        case forbidden(message: String = "You have no permission to access this resource.") // 403
        case notFound(message: String = "Resource not found.") // 404
        case serverError(code: Int) // 50x
        case decodingError(error: Error?)
        case noResponse
        
        var errorDescription: String? {
            switch self {
            case .badRequest(let message):
                return message
            case .unauthorized(let message):
                return message
            case .forbidden(let message):
                return message
            case .notFound(let message):
                return message
            case .serverError(let code):
                return "A server error with the code \(code) occurred."
            case .decodingError:
                return "There was an error when decoding the response."
            case .noResponse:
                return "The server did not respond."
            }
        }
    }
    
}
