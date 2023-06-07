import Foundation

extension JSONDecoder {
    enum DateError: String, Error {
        case invalidDate
    }
    
    static func JSONDateDecodingStrategy(decoder: Decoder) throws -> Date {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        if let date = formatter.date(from: dateStr) {
            return date
        }
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        if let date = formatter.date(from: dateStr) {
            return date
        }
        throw DateError.invalidDate
    }
}
