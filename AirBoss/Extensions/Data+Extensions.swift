//
//  Data+Extensions.swift
//  Air Boss
//
//  Created by Doug Haacke on 8/10/22.
//

import Foundation

extension Data {
    func toString() -> String {
        return  String(decoding: self, as: UTF8.self)
    }
    
    // parsing JSON
    init?(json: Any) {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed) else { return nil }
        self.init(data)
    }
    
    func jsonToDictionary() -> [String: Any]? {
        (try? JSONSerialization.jsonObject(with: self, options: .allowFragments)) as? [String: Any]
    }
    
    func jsonToArray() -> [Any]? {
        (try? JSONSerialization.jsonObject(with: self, options: .allowFragments)) as? [Any]
    }
}




