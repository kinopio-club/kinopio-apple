import Foundation

enum Networking {
    private static var baseURL: URL {
        Configuration.apiURL
    }
    
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(JSONDecoder.JSONDateDecodingStrategy)
        return decoder
    }()
    
    private static func handleResponse<R>(data: Data, response: HTTPURLResponse, onSuccess: () throws -> R) throws -> R {
        switch response.statusCode {
        case 200...299:
            return try onSuccess()
        case 400:
            if let response = APIResponse.parseFromData(data) {
                throw APIError.badRequest(message: response.message)
            }
            else {
                throw APIError.badRequest()
            }
        case 401:
            if let response = APIResponse.parseFromData(data) {
                throw APIError.unauthorized(message: response.message)
            }
            else {
                throw APIError.unauthorized()
            }
        case 403:
            if let response = APIResponse.parseFromData(data) {
                throw APIError.forbidden(message: response.message)
            }
            else {
                throw APIError.forbidden()
            }
        default:
            throw APIError.serverError(code: response.statusCode)
        }
    }
    
    private static func postRequest<C: Codable>(request originalRequest: URLRequest, data: Encodable, delegate: URLSessionTaskDelegate? = nil) async throws -> C {
        var request = originalRequest
        
        let jsonData = try! JSONEncoder().encode(data)
        
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("\(jsonData.count)", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await Networking.request(request: request, delegate: delegate)
    }
    
    private static func postRequest<C: Codable>(request originalRequest: URLRequest, data: [String: Any], delegate: URLSessionTaskDelegate? = nil) async throws -> C {
        var request = originalRequest
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("\(jsonData.count)", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await Networking.request(request: request, delegate: delegate)
    }
    
    private static func postRequest(request originalRequest: URLRequest, data: [String: Any]) async throws -> Data {
        var request = originalRequest
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("\(jsonData.count)", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await Networking.request(request: request)
    }
    
    private static func request(request: URLRequest, fromFile: URL? = nil, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, HTTPURLResponse) {
        var data: Data?
        var response: URLResponse?
        
        if let fromFile {
            (data, response) = try await URLSession.shared.upload(for: request, fromFile: fromFile, delegate: delegate)
        } else {
            (data, response) = try await URLSession.shared.data(for: request, delegate: delegate)
        }
        
        guard let response = response as? HTTPURLResponse, let data else {
            throw APIError.noResponse
        }
        
        return try handleResponse(data: data, response: response) {
            return (data, response)
        }
    }
    
    private static func request<C: Codable>(request: URLRequest, fromFile: URL? = nil, delegate: URLSessionTaskDelegate? = nil) async throws -> C {
        var data: Data?
        var response: URLResponse?
        
        if let fromFile {
            (data, response) = try await URLSession.shared.upload(for: request, fromFile: fromFile, delegate: delegate)
        } else {
            (data, response) = try await URLSession.shared.data(for: request, delegate: delegate)
        }
        
        guard let response = response as? HTTPURLResponse, let data else {
            throw APIError.noResponse
        }
        
        return try handleResponse(data: data, response: response) {
            do {
                return try decoder.decode(C.self, from: data)
            } catch {
                throw APIError.decodingError(error: error)
            }
        }
    }
    
    // MARK: Public Functions
    
    static func getUserInboxSpace(token: String) async throws -> Space {
        let url = baseURL.appendingPathComponent("user/inbox-space")
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        return try await self.request(request: request)
    }
    
    static func getUser(token: String) async throws -> User {
        let url = baseURL.appendingPathComponent("user")
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        return try await self.request(request: request)
    }
    
    static func getUserSpaces(token: String) async throws -> [Space] {
        let url = baseURL.appendingPathComponent("user/spaces")
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        return try await self.request(request: request)
    }
    
    static func createCard(token: String, card: Card) async throws -> Card {
        let url = baseURL.appendingPathComponent("card")
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        return try await Networking.postRequest(request: request, data: card)
    }
    
    static func getJournalDailyPrompt() async throws -> JournalDailyPrompt {
        let url = baseURL.appendingPathComponent("journal-daily-prompt")
        var request = URLRequest(url: url)
        
        return try await Networking.request(request: request)
    }
    
}
