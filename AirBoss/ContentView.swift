//
//  ContentView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/1/24.
//

import SwiftUI
import SwiftData
import Observation
import Combine

import AudioToolbox

struct ContentView: View {
    
    // MARK: - PROPERTIES
    //    @Environment(\.modelContext) private var modelContext
    //    @Query private var items: [Item]
    @Environment(LocationManager.self) var locationManager
    
    @State private var homeLocation: HomeLocation?
    @State private var websocket = Websocket()
    @State private var adsb : ADSB = Bundle.main.decode("ADSB.json")
    @State private var isLoading = false
    
    // MARK: - FUNCTIONS
    func nothing() {
    }
    
    // MARK: - BODY
    var body: some View {
        
        ZStack {
            Color(.darkGray).ignoresSafeArea(.all, edges: .all)
            HStack {
                if isLoading {
                    ProgressView()
                    Text("Loading...")
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading) {
                            DayWeatherView()
                            Spacer()
                            CurrentWeatherView()
                            Spacer()
                        }
                        .padding()
                    }
               }
               VStack {
                   MapView()
                   
               }
            }
        }
        // .frame(width: visible ? .infinity : 0, height: visible ? .infinity : 0, alignment: .center)
        .onReceive(Just(websocket.message)) { _ in
            // print("---> Just onReceive message: \(websocket.message)")
            // AudioServicesPlaySystemSound(1026)
        }
        .onReceive(Just(websocket.adsb)) { _ in
            if websocket.adsb != nil {
                adsb = websocket.adsb!
            }
        }
        .task(id: locationManager.currentLocation) {
            isLoading = true
            if let currentLocation = locationManager.currentLocation {
                homeLocation = currentLocation
                if let lat = homeLocation?.latitude, let lon = homeLocation?.longitude {
                    print("\(lat),  \(lon)")
                    isLoading = false
                }
            }
        }
    }
}


#Preview {
    // @State var adsb: ADSB = Bundle.main.decode("adsb.json")

    ContentView()
    //     .modelContainer(for: Item.self, inMemory: true)
}
