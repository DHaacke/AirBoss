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
    
    var body: some View {
        VStack {
            Image(systemName: "flame")
                .renderingMode(.template)
                .resizable()
                .symbolVariant(.fill)
                .foregroundStyle(.yellow)
                .frame(width: 64, height: 64, alignment: .bottom)
                .background(.clear)
                .onTapGesture {
                    dismiss()
                }
            Text(text!)
                .font(.system(size: 14.0, weight: .medium))
                .padding(8)
                .minimumScaleFactor(0.8)
                .background {
                     Color.colorBlackLight
                }

            Map(position: $position) {
                if let coord = coordinate {
                    Annotation("Fire Location", coordinate: coord) {
                        Image(systemName: "flame")    // .rotationEffect(.degrees(270))
                    }
                }
            }
            .mapStyle(.imagery)
            .onMapCameraChange { context in
                print("Map Camera change")
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
            .font(.title)
            .padding()
            .background(.black)
        }
        .frame(width: 400, height: 800)
        .onAppear  {
            if let coordinate {
                position = MapCameraPosition.region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 9, longitudeDelta: 9)
                    )
                )
                visibleRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 9.0, longitudeDelta: 9.0))
            }
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
    
    @State private var isShowingNotamText = false
    @State private var isShowingSheet = false
    
    @State var textSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            VStack {
                Button("", systemImage: "flame") {
                    isShowingSheet.toggle()
                }
                .sheet(isPresented: $isShowingSheet, content: {
                    NotamSheetView(text: text!, coordinate: coordinate)
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
                print("Tapped!")
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

