//
//  NotanAnnotationView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/14/24.
//

import Foundation
import SwiftUI
import MapKit

struct NotamSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(LocationManager.self) var locationManager
    
    @State private var position: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    
    var freq: String?
    var text: String?
    var coordinate: CLLocationCoordinate2D?
    var polygons: [CLLocationCoordinate2D]?
    
    var body: some View {
        VStack {
            Image(systemName: "flame")
                .renderingMode(.template)
                .resizable()
                .symbolVariant(.fill)
                .foregroundStyle(.yellow)
                .frame(width: 64, height: 64, alignment: .bottom)
                .background(.clear)
                .padding(.top, 8)
                .onTapGesture {
                    dismiss()
                }
            if let freq {
                Text(freq)
                    .font(.system(size: 16.0, weight: .medium))
            }
            Text(text!)
                .font(.system(size: 14.0, weight: .medium))
                .padding(6)
                .minimumScaleFactor(0.7)
                .background {
                     Color.colorBlackLight
                }

            Map(position: $position) {
                if let coord = coordinate {
                    Annotation("Fire Location", coordinate: coord) {
                        Image(systemName: "flame")    // .rotationEffect(.degrees(270))
                    }
                }
                if let polygons {
                    if polygons.count > 0 {
                        MapPolygon(coordinates: polygons)
                            .foregroundStyle(.orange.opacity(0.4))
                            .stroke(.orange.opacity(0.5), lineWidth: 2)
                    }
                }
            }
            .mapStyle(.imagery)
            .onMapCameraChange { context in
                visibleRegion = context.region
            }
            .mapFeatureSelectionDisabled { _ in false }
            
            Button {
                dismiss()
            } label: {
                Label("", systemImage: "x.circle")
                    .padding()
                    .foregroundStyle(.white)
            }
            .buttonStyle(PlainButtonStyle())
            .background(.clear)
            .font(.title)
            .padding()
        }
        .padding(.top, 8)
        // .frame(width: 400, height: 650)
        .frame(minWidth: 300, idealWidth: 400, maxWidth: 400, minHeight: 500, idealHeight: .infinity, maxHeight: .infinity)
        .onAppear  {
            if let coordinate {
                position = MapCameraPosition.region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    )
                )
                visibleRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            }
            
//            if let geoArray = geometries {
//                if geoArray.count > 0 {
        }
        
    }
}

//#Preview {
//    NotamSheetView()
//}

// Create the custom view
struct NotamAnnotationView: View {
    var title: String?
    var subtitle: String?
    var text: String?
    var coordinate: CLLocationCoordinate2D?
    var polygons: [CLLocationCoordinate2D]?
    
    @State private var isShowingNotamText = false
    @State private var isShowingSheet = false
    
    @State var textSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            VStack {
                Button("", systemImage: "flame") {
                    isShowingSheet.toggle()
                }
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: $isShowingSheet, content: {
                    NotamSheetView(freq: title!, text: text!, coordinate: coordinate, polygons: polygons)
                })

//                Image(systemName: "flame")
//                    .renderingMode(.original)
//                    .symbolVariant(.fill)
//                    .foregroundStyle(.yellow)
//                    .frame(width: 44, height: 44, alignment: .bottom)
//                    .background(.clear)
//                    .opacity(0.8)
//                    .sheet(isPresented: $isShowingSheet) {
//                        NotamSheetView(text: text!)
//                    }
                Text(title!)
                    .font(.system(size: 10, weight: .medium))
                    .frame(width: 90, height: 12, alignment: .bottom)

//                if isShowingNotamText {
//                    VStack {
//                        HStack() {
//                            Spacer()
//                            Button(action: {
//                                isShowingNotamText.toggle()
//                                print("Button pressed!")
//                             }) {
//                                 Image(systemName: "x.circle")
//                                     .foregroundColor(.white)
//                            }
//                             .buttonStyle(.plain)
//                             .onTapGesture {
//                                 isShowingNotamText.toggle()
//                             }
//                            .padding(.top, 10)
//                        }
//                        .frame(width: 260, height: 12, alignment: .trailing)
//                        Text(text!)
//                            .font(.system(size: 9.0, weight: .medium))
//                            .frame(width: 260, height: CGFloat(((text?.count ?? 260) / 40) * 10), alignment: .topLeading)  // 84 chars per line
//                            .padding(8)
//                            .minimumScaleFactor(0.9)
//                            .background {
//                                 Color.colorBlackLight
//                            }
//                            .onTapGesture {
//                                isShowingNotamText.toggle()
//                            }
//                    }
//                    .background {
//                         Color.colorBlackLight
//                    }
//                    .onTapGesture {
//                        isShowingNotamText.toggle()
//                    }
//                } else {
//                    VStack {
//                        Text(" ")
//                    }
//                }
            }
            .onTapGesture {
                isShowingNotamText.toggle()
                
            }
       }
   }
}
   

//    var notam: NotamData
//    
//    var notamAnnotation: NotamAnnotation?
//    
//    var body: some View {
//        ZStack {
//            if let notamAnnotation {
//                Image(systemName: notamAnnotation.imageName!)
//                Text(notamAnnotation.title!)
//                    .font(.headline)
//                Text(notamAnnotation.subtitle!)
//                    .font(.subheadline)
//            }
//        }
//        .onAppear() {
//            let notamAnnotation = NotamAnnotation(coordinate: notam.coordinate, title: notam.freq, subtitle: "subtitle", imageName: "flame", text: notam.text)
//        }
//    }

