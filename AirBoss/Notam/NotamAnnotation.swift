//
//  NotanAnnotation.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/14/24.
//

import Foundation
import SwiftUI
import MapKit

class NotamAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var imageName: String?
    var text: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, imageName: String, text: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.text = text
    }
}
