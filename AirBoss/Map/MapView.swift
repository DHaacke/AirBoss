//
//  MapView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/4/24.
//

import SwiftUI
import MapKit
import WeatherKit

extension CLLocationCoordinate2D {
    static let locations = [
    CLLocationCoordinate2D(latitude: 11.3844028, longitude: 45.6174815),
    CLLocationCoordinate2D(latitude: 11.5608707, longitude: 45.3305094),
    CLLocationCoordinate2D(latitude: 11.8533817, longitude: 45.4447992),
    CLLocationCoordinate2D(latitude: 11.8382755, longitude: 45.6314077),
    CLLocationCoordinate2D(latitude: 11.6624943, longitude: 45.6942722),
    CLLocationCoordinate2D(latitude: 11.3844028, longitude: 45.6174815)]
}


struct MapView: View {
    let weatherManager = WeatherManager.shared
    @Environment(LocationManager.self) var locationManager
    // 45.79208074322167, -108.56983021630413
    
    @State private var position: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?

    @State private var notams: [NotamData] = []
    
    @State private var isShowingNotam = false

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
                            if notam.coordinate.latitude != 0 && notam.coordinate.longitude != 0 {
                                Annotation("", coordinate: notam.coordinate) {
                                    NotamAnnotationView(title: notam.freq, subtitle: "", text: notam.text, coordinate: notam.coordinate)
                                }
                                
                                if notam.polygons.count > 0 {
                                    MapPolygon(coordinates: notam.polygons)  // CLLocationCoordinate2D.locations
                                        .foregroundStyle(.orange.opacity(0.9))
                                        .stroke(.orange.opacity(0.7), lineWidth: 8)
                                }
                            }
                            
                        }
                    }
                }
            }
            .ignoresSafeArea()
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


