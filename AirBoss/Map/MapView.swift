//
//  MapView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/4/24.
//

import SwiftUI
import MapKit
import WeatherKit

struct MapView: View {
    let weatherManager = WeatherManager.shared
    @Environment(LocationManager.self) var locationManager
    // 45.79208074322167, -108.56983021630413
    
    @State private var position: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?

    @State private var notams: [NotamData] = []

    let notamManager = NotamManager()
    
    // 45.79211066654558, -108.56983021628744
    
    var body: some View {
        VStack {
            Map(position: $position) {  // , interactionModes: [.pan, .zoom]
                if let coord = locationManager.currentLocation?.coordinate {
                    if notams.count > 0 {
                        Annotation("Home", coordinate: coord) {
                            HeliAnimationView(bodyName: "L1TL", rotorName: "ROTOR-00")
                        }
                        ForEach(notams, id: \.self.id) { notam in
                            Annotation("Fire", coordinate: notam.coordinate) {
                                NotamAnnotationView()
                            }
                        }
                        
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .onMapCameraChange { context in
                visibleRegion = context.region
            }
            
        }
        .frame(minWidth: 400, idealWidth: .infinity, maxWidth: .infinity, minHeight: 800, idealHeight: .infinity, maxHeight: .infinity)
        .cornerRadius(12)
        .onAppear() {
            Task.detached { @MainActor in
                do {
                    if let lat = locationManager.userLocation?.coordinate.latitude, let lon = locationManager.userLocation?.coordinate.longitude {
                        notams = try await notamManager.getNotams(latitude: lat, longitude: lon)!
                        print("Notams:  \(notams.count)")
                        // dump(notam, indent: 4)
                        
                    }
                } catch {
                    print("Notams Task Error")
                }
            }
        }
    }
}

//#Preview {
//    MapView(, notams: <#[NotamData]#>)
//        .environment(LocationManager())
//}
