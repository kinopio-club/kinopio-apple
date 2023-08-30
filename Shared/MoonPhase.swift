import Foundation
import SwiftUI

enum MoonPhase: Int {
    case newMoon,
         waxingCrescent,
         waxingQuarter,
         waxingGibbous,
         fullMoon,
         waningGibbous,
         waningQuarter,
         waningCrescent
    
    var emoji: String {
        switch self {
        case .newMoon:
            return "🌑"
        case .waxingCrescent:
            return "🌒"
        case .waxingQuarter:
            return "🌓"
        case .waxingGibbous:
            return "🌔"
        case .fullMoon:
            return "🌕"
        case .waningGibbous:
            return "🌖"
        case .waningQuarter:
            return "🌗"
        case .waningCrescent:
            return "🌘"
        }
    }
    
    private static func getPhase(year: Int, month: Int, day: Int) -> Int {
        var year = year
        var month = month
        var c = 0.0
        var e = 0.0
        var jd = 0.0
        var phase = 0
        
        if month < 3 {
            year -= 1
            month += 12
        }
        month += 1
        c = 365.25 * Double(year)
        e = 30.6 * Double(month)
        
        jd = c + e + Double(day) - Double(694039.09) // jd is total days elapsed
        jd /= 29.5305882 // divide by the moon cycle
        phase = Int(jd) // int(jd) -> phase, take integer part of jd
        jd -= Double(phase) // subtract integer part to leave fractional part of original jd
        phase = Int((jd * 8).rounded()) // scale fraction from 0-8 and round
        if phase >= 8 {
            phase = 0 // 0 and 8 are the same so turn 8 into 0
        }
        
        return phase
    }
    
    static func getFrom(date: Date = Date()) -> MoonPhase {
        let day = Calendar.current.component(.day, from: date)
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        
        let phase = MoonPhase.getPhase(year: year, month: month, day: day)
        return MoonPhase(rawValue: phase)!
    }
    
}

extension MoonPhase {
    
    var image: Image {
        switch self {
        case .newMoon:
            return Image("NewMoon")
        case .waxingCrescent:
            return Image("WaxingCrescent")
        case .waxingQuarter:
            return Image("WaxingQuarter")
        case .waxingGibbous:
            return Image("WaxingGibbous")
        case .fullMoon:
            return Image("FullMoon")
        case .waningGibbous:
            return Image("WaningGibbous")
        case .waningQuarter:
            return Image("WaningQuarter")
        case .waningCrescent:
            return Image("WaningCrescent")
        }
    }
    
}
