//
//  Double+Extensions.swift
//  Air Boss
//
//  Created by Doug Haacke on 8/4/22.
//

import Foundation

extension Double {
    func format(suffix: String, decimals: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true
        if decimals == 0 {
          numberFormatter.minimumFractionDigits = 0
          numberFormatter.maximumFractionDigits = 0
        } else {
          numberFormatter.minimumFractionDigits = decimals
          numberFormatter.maximumFractionDigits = decimals
        }
        let rs = numberFormatter.string(for: self) ?? "0"
        return "\(rs)\(suffix)"
    }
    func toInt() -> Int? {
        if self >= Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    func milesToMeters() -> Double {
        return self * 1609.34
    }
    func milesToKilometers() -> Double {
        return self * 1.60934
    }
    func feetToMeters() -> Double {
        return self * 3.048
    }
    func metersToFeet() -> Double {
        return self / 3.048
    }
    func metersToMiles() -> Double {
        return self / 1609.34
    }
    func kilometersToMiles() -> Double {
        return self / 1.60934
    }
    func degreesToRadians() -> Double {
        return self * .pi / 180.0
    }
    func radiansToDegrees() -> Double {
        return self * 180.0 / .pi
    }
    
}

