import SwiftUI
import RegexBuilder

#if os(iOS)
typealias PlatformColor = UIColor
#elseif os(macOS)
typealias PlatformColor = NSColor
#endif

extension Color {
    static let secondaryBackground = Color("SecondaryBackground")
}

extension Color {
    var isDark: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  luminance < 0.40
    }
}

extension Color {
    init(hex string: String) {
        var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }
        
        // Double the last value if incomplete hex
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }
        
        // Fix invalid values
        if string.count > 8 {
            string = String(string.prefix(8))
        }
        
        // Scanner creation
        let scanner = Scanner(string: string)
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        if string.count == 2 {
            let mask = 0xFF
            
            let g = Int(color) & mask
            
            let gray = Double(g) / 255.0
            
            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)
            
        } else if string.count == 4 {
            let mask = 0x00FF
            
            let g = Int(color >> 8) & mask
            let a = Int(color) & mask
            
            let gray = Double(g) / 255.0
            let alpha = Double(a) / 255.0
            
            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)
            
        } else if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask
            
            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
            
        } else if string.count == 8 {
            let mask = 0x000000FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask
            
            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0
            
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
            
        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }
}

extension Color {
    init(rgb string: String) {
        var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let digits = Regex {
            Optionally(.whitespace)
            Capture {
                Repeat(1...3) {
                    One(.digit)
                }
            }
            Optionally(.whitespace)
        }
        let pattern = Regex {
            "rgb("
            digits
            ","
            digits
            ","
            digits
            ")"
        }.ignoresCase()
        
        if let match = string.firstMatch(of: pattern) {
            let (_, red, green, blue) = match.output
            guard let red = Double(red), let green = Double(green), let blue = Double(blue) else {
                self.init(.sRGB, red: 1, green: 1, blue: 1)
                return
            }
            
            self.init(.sRGB, red: red / 255, green: green / 255, blue: blue / 255)
        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1)
        }
    }
}

extension Color: RawRepresentable {
    
    public init?(rawValue: String) {
        
        guard let data = Data(base64Encoded: rawValue) else {
            self = .black
            return
        }
        
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: PlatformColor.self, from: data) ?? .black
            self = Color(color)
        } catch {
            self = .black
        }
        
    }
    
    public var rawValue: String {
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: PlatformColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
        
    }
}
