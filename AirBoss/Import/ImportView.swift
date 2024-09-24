//
//  ImportView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/20/24.
//

import Foundation
import SwiftData
import SwiftUI

struct ImportView: View {
    @Environment(\.modelContext) var modelContext
    @Query var aircraft: [Aircraft]
    @State private var maxDate: Date = .now.addingTimeInterval(86400 * -10)
    @State private var status: String = ""
    @State private var isProcessing: Bool = false
    @State private var isComplete: Bool = false
    @State private var isShowingAlert = false
    @State private var workingItem: String = ""
    
    private var minimumDate: Date?
    
    let aircraftFetchDescriptor: FetchDescriptor<Aircraft>
    let icaoTypeFetchDescriptor: FetchDescriptor<IcaoType>
    
    var body: some View {
        ZStack {
            Color.customBlackLight
                .cornerRadius(40)
                .opacity(0.85)
          
            LinearGradient(
                colors: [.customBlackLight, .customBlackDark],
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(40)
            VStack {
                Text("Last database refresh occurred on:")
                    .foregroundStyle(.white)
                    .font(.headline)
                Text("\(maxDate.format(format: "yyyy-MM-dd"))")
                    .foregroundStyle(.white)
                    .padding()
                Text("\(status)")
                    .foregroundStyle(.green)
                    .padding()
                
                Text("\(workingItem)")
                
                if isComplete {
                    Divider()
                    if let aircraftCount = try? modelContext.fetchCount(aircraftFetchDescriptor), let icaoTypeCount = try? modelContext.fetchCount(icaoTypeFetchDescriptor) {
                        Text("Total Aircraft: \(aircraftCount)")
                        Text("Total Aircraft Types: \(icaoTypeCount)")
                    }
                                    }


                
                if !isProcessing {
                    Button("Refresh Aircraft database") {
                        Task {
                            Task.detached { @MainActor in
                                isProcessing = true
                                isComplete = false
                                status = "Downloading..."
                            }
                            try await processAircraft(modelContainer: modelContext.container, replace: true)
                            Task.detached { @MainActor in
                                status = "Done processing!"
                                isComplete = true
                                isProcessing = false
                            }
                        }
                    }
                    .buttonStyle(BlueButton())
                    
                    Button("Replace Aircraft database") {
                        isShowingAlert = true
                    }
                    .buttonStyle(RedButtonView())
                    .padding()
                    .alert(isPresented: $isShowingAlert) {
                        Alert(
                            title: Text("Are you sure you want replace the aircraft database?"),
                            message: Text("WARNING: This can take several hours or more to complete."),
                            primaryButton: .destructive(Text("Proceed")) {

                                Task {
                                    Task.detached { @MainActor in
                                        isProcessing = true
                                        isComplete = false
                                        status = "Downloading..."
                                    }

                                    try await processAircraft(modelContainer: modelContext.container, replace: true)
                                    Task.detached { @MainActor in
                                        status = "Done processing!"
                                        isComplete = true
                                        isProcessing = false
                                    }
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            .onAppear() {
                if let plane = aircraft.first {
                    maxDate = plane.date
                } else {
                    maxDate = .distantPast
                }
            }
            .onChange(of: maxDate, initial: false) { maxDate, prevDate in
                print("Date changed!  \(maxDate) vs \(prevDate)")
            }
        }
        .frame(width: 500, height: 600)
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.accentColor, lineWidth: 2))
            
    }
    
    init(minimumDate: Date) {
        print("Initializing with minimum date: \(minimumDate.format(format: "yyyy-MM-dd"))")
        _aircraft = Query(filter: #Predicate<Aircraft> { aircraft in
            aircraft.date < minimumDate
        }, sort: \Aircraft.date, order: .reverse)
        let distantPast = Date.distantPast
        aircraftFetchDescriptor = FetchDescriptor<Aircraft>(predicate: #Predicate { aircraft in
            aircraft.date > distantPast
        })
        icaoTypeFetchDescriptor = FetchDescriptor<IcaoType>(predicate: #Predicate { icaoType in
            icaoType.date > distantPast
        })
    }
    
    nonisolated func processAircraft(modelContainer: ModelContainer, replace: Bool) async throws {
        Task.detached { @MainActor in
            status = "Downloading aircraft..."
        }
        let jsonData = try? await getAircraftJSON(maxDate: maxDate)
        if let jsonData = jsonData {
            await decodeAircraft(with: jsonData, modelContainer: modelContainer, replace: replace)
        } else {
            print("getAircraftJSON did not return valid data.")
        }
        
    }
    
    nonisolated func getAircraftJSON(maxDate: Date) async throws -> Data? {
        let urlString = URL(string: "https://data.bighornriver.org/aircraft/\(maxDate.format(format: "yyyy-MM-dd"))")!
        print(urlString)
        var request = URLRequest(url: urlString)
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        Task.detached { @MainActor in
            status = "Downloading aircraft data..."
        }
        let (data, response) = try await URLSession.shared.data(for: request as URLRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("JSON: There was an error trying \(urlString)")
            return nil
        }
        return data
    }
        
    nonisolated func decodeAircraft(with data: Data, modelContainer: ModelContainer, replace: Bool) async -> Void {
        let context = ModelContext(modelContainer)
        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                if let jsonMasterObject = jsonResult.value(forKey: "master") as? NSObject {
                    if let icaoTypeList = jsonMasterObject.value(forKey: "icaoType") as? NSArray {
                        var lap = 0
                        var count = 0.0
                        let total = Double(icaoTypeList.count)
                        Task.detached { @MainActor in
                            status = "Processing Icao Types..."
                        }
                        if replace {
                            try? context.delete(model: IcaoType.self)
                        }
                        for json in icaoTypeList {
                            if let icaoTypeData = json as? [String: AnyObject] {
                                Task.detached { @MainActor in
                                    workingItem = "\(((count / total) * 100.0).format(suffix: "%", decimals: 0))"
                                }
                                let icaoTypeModel = IcaoType(icaoType: icaoTypeData["icao_type"] as? String ?? "",
                                                             manufacturer: icaoTypeData["manufacturer"] as? String ?? "",
                                                             model: icaoTypeData["model"] as? String ?? "",
                                                             icon: icaoTypeData["icon"] as? String ?? "",
                                                             altIcon: icaoTypeData["altIcon"] as? String ?? "",
                                                             date: .now)
                                context.insert(icaoTypeModel)
                                
                                if count == 10 || lap > 500 {
                                    sleep(1)
                                    lap = 0
                                } else {
                                    lap += 1
                                }
                                count += 1.0
                            }
                        }
                    } else {
                        print("Could not decode icaoType array")
                    }
                    if let aircraftList = jsonMasterObject.value(forKey: "aircraft") as? NSArray {
                        var lap = 0
                        var count = 0.0
                        let total = Double(aircraftList.count)
                        print("total: \(total)")
                        Task.detached { @MainActor in
                            status = "Processing Aircraft..."
                        }
                        if replace {
                            try? context.delete(model: Aircraft.self)
                        }
                        for json in aircraftList {
                            if let aircraftData = json as? [String: AnyObject] {
                                
                                let aircraftIcaoType = aircraftData["icao_type"] as? String ?? ""
                                var fetchDescriptor = FetchDescriptor<IcaoType>(predicate: #Predicate { icaoType in
                                    icaoType.icaoType == aircraftIcaoType
                                })
                                fetchDescriptor.fetchLimit = 1
                                
                                if count < 50 {

                                    let progress = (count / total) * 100.0
                                    
                                    Task.detached { @MainActor in
                                        workingItem = "\(progress.format(suffix: "%", decimals: 0))"
                                    }
                                    
                                    do {
                                        let it = try context.fetch(fetchDescriptor)
                                        
                                        if it.count == 1 {
                                            Task.detached { @MainActor in
                                                workingItem = "\(it[0].icaoType):  \(progress.format(suffix: "%", decimals: 0))"
                                            }
                                            let aircraftModel = Aircraft(icao: aircraftData["icao"] as? Int64 ?? 0,
                                                                         callSign: aircraftData["callsign"] as? String ?? "",
                                                                         reg: aircraftData["reg"] as? String ?? "",
                                                                         owner: aircraftData["owner"] as? String ?? "",
                                                                         mil: aircraftData["mil"] as? String ?? "",
                                                                         alert: aircraftData["alert"] as? String ?? "",
                                                                         date: Date.now)
                                            aircraftModel.icaoType = it[0]
                                            
                                            if count == 1.0 {
                                                print("\(aircraftModel)")
                                            }
                                            
                                            context.insert(aircraftModel)
                                        }
                                        count += 1.0
                                        lap += 1
                                        if lap > 5000 {
                                            sleep(1)
                                            lap = 0
                                        }
                                    } catch {
                                        fatalError("Failed to fetch aircraft: \(error.localizedDescription)")
                                    }
                                    
                                }
                            }
                        }
                    
                    } else {
                        print("Could not decode aircraft array")
                    }
                    try? context.save()
                }
            } else {
                print(" * * Could not read master JSON")
            }
        }
        catch let DecodingError.dataCorrupted(context) {
          print("JSON: \(context)")
        } catch let DecodingError.keyNotFound(key, context) {
            print("JSON Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("JSON Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("JSON Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
           print("\(error.localizedDescription)")
        }
        
    }
      
    
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

#Preview {
    do {
        let previewer = try Previewer()

        return ImportView(minimumDate: .now)
            .modelContainer(previewer.container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}


/*
 https://www.hackingwithswift.com/quick-start/swiftdata/how-to-filter-swiftdata-results-with-predicates
 https://www.youtube.com/watch?v=bV5KnqMHXe0
*/
