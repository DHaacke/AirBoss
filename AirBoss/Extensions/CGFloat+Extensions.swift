//
//  CGFloat+Extensions.swift
//  Air Boss Pro
//
//  Created by Doug Haacke on 1/27/24.
//

import Foundation

extension CGFloat {
    
    func toRadians() -> CGFloat {
            return self / (180 * .pi)
        }
        
    func toDegrees() -> CGFloat {
        return self * (180 * .pi)
    }
}
