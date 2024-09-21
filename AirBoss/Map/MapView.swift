//
//  MapView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/4/24.
//

import SwiftUI
import MapKit
import WeatherKit
import Combine

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

    var isShowingNotams : Bool
    
    let weatherManager = WeatherManager.shared
    @Environment(LocationManager.self) var locationManager
    
    @State private var webSocketManager = WebSocketManager()
 
    @State private var trafficList: [TrafficModel] = []
    
    var traffic: TrafficModel?
    
    @State private var isConnected: Bool = false
    
    // 45.79208074322167, -108.56983021630413
    
    // @State private var position: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?


    @State private var notams: [NotamData] = []
    
    @State var isShowingNotam = false

    let notamManager = NotamManager()
    
    
    let timer = Timer.publish(every: 20, on: .main, in: .common).autoconnect()
    
    
    
    // 45.79211066654558, -108.56983021628744
    
    var body: some View {
        let position = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locationManager.currentLocation?.coordinate.latitude ?? 0, longitude: locationManager.currentLocation?.coordinate.longitude ?? 0),
                                                                   span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
        VStack {
            if locationManager.isLocationUpdated {
                Map(initialPosition: position) {
                    if isShowingNotams {
                        if let coord = locationManager.currentLocation?.coordinate {
                            if notams.count > 0 {
                                Annotation("Home", coordinate: coord) {
                                    HeliAnimationView(bodyName: "L1TL", rotorName: "ROTOR-00")
                                }
                                ForEach(notams, id: \.self.id) { notam in
                                    if notam.coordinate.latitude != 0 && notam.coordinate.longitude != 0 {
                                        Annotation("", coordinate: notam.coordinate) {
                                            NotamAnnotationView(title: notam.freq, subtitle: "", text: notam.text, coordinate: notam.coordinate, polygons: notam.polygons)
                                        }
                                        if notam.polygons.count > 0 {
                                            MapPolygon(coordinates: notam.polygons)
                                                .foregroundStyle(.orange.opacity(0.4))
                                                .stroke(.orange.opacity(0.5), lineWidth: 2)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    ForEach(trafficList, id: \.self.icaoAddress) { traffic in
                        Annotation("", coordinate: traffic.coordinate, anchor: .center) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                TrafficAnnotationView(traffic: traffic)
                            }
                        }

                    }
                }
                // .setUserTrackingMode(.follow, animated: true)
                .ignoresSafeArea()
                .mapStyle(.standard(elevation: .realistic))
                .onMapCameraChange { context in
                    visibleRegion = context.region
                }
                
                .onReceive(Just(webSocketManager.traffic), perform: { traffic in
                    if let traffic = traffic {
                        // dump(traffic, indent: 4)
                        Task.detached { @MainActor in
                            let filteredTraffic = trafficList.filter{ item in
                                return item.icaoAddress == traffic.icaoAddress
                            }
                            if filteredTraffic.count == 0 {
                                trafficList.append(traffic)
                            } else {
                                if let coordinate = locationManager.userLocation?.coordinate {
                                    filteredTraffic[0].homeLocation = coordinate
                                }
                                if let elevation = locationManager.userLocation?.altitude {
                                    filteredTraffic[0].homeElevation = Int(elevation)
                                }
                                filteredTraffic[0].priority = traffic.priority
                                filteredTraffic[0].onGround = traffic.onGround
                                filteredTraffic[0].squawk = traffic.squawk
                                filteredTraffic[0].lat = traffic.lat
                                filteredTraffic[0].lon = traffic.lon
                                filteredTraffic[0].altitude = traffic.altitude
                                filteredTraffic[0].course = traffic.course
                                filteredTraffic[0].speed = traffic.speed
                                filteredTraffic[0].distance = traffic.distance
                                filteredTraffic[0].bearing = traffic.bearing
                                filteredTraffic[0].vvel = traffic.vvel
                                filteredTraffic[0].turnRate = traffic.turnRate
                                filteredTraffic[0].timeStamp = Date().currentTimeStamp()
                                trafficList = trafficList.map(\.self)
                            }
                        }
                    }
                })
                .onReceive(timer) { time in
                    // print("The time is now \(time)")
                    var list : [TrafficModel] = []
                    for traffic in trafficList {
                        if Date().currentTimeStamp() - traffic.timeStamp < 15000 {
                            list.append(traffic)
                        }
                    }
                    if list.count < trafficList.count {
                        Task.detached { @MainActor in
                            trafficList = list
                        }
                    }
                }

            } else {
                Text("Preparing map")
                ProgressView()
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

/*
#Preview {
    MapView(isShowingNotams: false)
        .environment(LocationManager())
        .environment(NotamManager())
}
*/


