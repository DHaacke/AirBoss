//
//  EnvironmentKeys.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/15/24.
//

import SwiftUI

struct AppIsShowingWeather: EnvironmentKey {
    static var defaultValue: Bool = false
}

struct AppIsShowingNotams: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var isShowingWeather: Bool {
        get {
            self[AppIsShowingWeather.self]
        }
        set {
            self[AppIsShowingWeather.self] = newValue
        }
    }
    
    var isShowingNotams: Bool {
        get {
            self[AppIsShowingNotams.self]
        }
        set {
            self[AppIsShowingNotams.self] = newValue
        }
    }
}

extension View {
    func isShowingWeather(_ enabled: Bool) -> some View {
        environment(\.isShowingWeather, enabled)
    }
    func isShowingNotams(_ enabled: Bool) -> some View {
        environment(\.isShowingNotams, enabled)
    }
}
