//
//  Date.swift
//  FPV Copilot
//
//  Created by Doug Haacke on 6/11/22.
//

import Foundation

extension Date {

    func formatLarge(dt: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM y, HH:mm"
        formatter.timeZone = .current // TimeZone(abbreviation: "UTC")
        let result = formatter.string(from: dt)
        return result
    }
    func currentTimeStamp() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    func format(format: String) -> String {
        let formatter = DateFormatter()
        // formatter.dateFormat = "MMMM dd, yyyy 'at' hh:mm:ss a 'UTC'Z" //If you dont want static "UTC" you can go for ZZZZ instead of 'UTC'Z.
        formatter.dateFormat = format
        formatter.timeZone = .current // TimeZone(abbreviation: "UTC")
        let result = formatter.string(from: self)
        return result
    }
    
    func formatDateTime(dt: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format        // "E, d MMM y, HH:mm"
        formatter.timeZone = .current        // TimeZone(abbreviation: "UTC")
        let result = formatter.string(from: dt)
        return result
    }
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
