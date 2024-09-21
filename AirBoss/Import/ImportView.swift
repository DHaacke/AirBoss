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
    @State private var progressValue: Double = 0.0
    @State private var progressTitle: String = ""
    
    private var minimumDate: Date?
    
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
                Text("\(maxDate.format(format: "yyyy-MM-dd"))")
                    .foregroundStyle(.white)
                    .padding()
                Text("\(status)")
                    .foregroundStyle(.green)
                    .padding()

                if isProcessing {
                    ProgressView("Processing", value: 0.10)
                        .progressViewStyle(.circular)
                }
                

            }
            .onAppear() {
                if let plane = aircraft.first {
                    maxDate = plane.date
                } else {
                    maxDate = .distantPast
                }
            }
            .onChange(of: maxDate, initial: false) { maxDate, otherDate in
                print("Date changed!  \(maxDate) vs \(otherDate)")
                Task.detached { @MainActor in
                    isProcessing = true
                    let jsonData = try? await getAircraftJSON(maxDate: otherDate)
                    if let jsonData = jsonData {
                        isProcessing = true
                        decodeAircraft(with: jsonData, completion: {
                            print("All Done!")
                            status = "All done!"
                            isProcessing = false
                        })
                    } else {
                        print("getAircraftJSON did not return valid data.")
                    }
                    isProcessing = false
                }
            }
        }
        .frame(width: 500, height: 500)
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.accentColor, lineWidth: 2))
            
    }
    
    init(minimumDate: Date) {
        print("Initializing with minimum date: \(minimumDate.format(format: "yyyy-MM-dd"))")
        _aircraft = Query(filter: #Predicate<Aircraft> { aircraft in
            aircraft.date < minimumDate
        }, sort: \Aircraft.date, order: .reverse)
    }
    
    func getAircraftJSON(maxDate: Date) async throws -> Data? {
        let urlString = URL(string: "https://data.bighornriver.org/aircraft/\(maxDate.format(format: "yyyy-MM-dd"))")!
        print(urlString)
        var request = URLRequest(url: urlString)
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        status = "Downloading..."
        let (data, response) = try await URLSession.shared.data(for: request as URLRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("JSON: There was an error trying \(urlString)")
            return nil
        }
        return data
    }
    
    func decodeAircraft(with data: Data, completion: @escaping () -> Void) {
        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                if let jsonMasterObject = jsonResult.value(forKey: "master") as? NSObject {
                    if let icaoTypeList = jsonMasterObject.value(forKey: "icaoType") as? NSArray {
                        loadIcaoType(from: icaoTypeList, completion: { count in
                            print("Loaded \(count) icaoType...")
                            if let aircraftList = jsonMasterObject.value(forKey: "aircraft") as? NSArray {
                                loadAircraft(from: aircraftList, completion: { count in
                                    print("Loaded \(count) aircraft...")
                                })
                            } else {
                                print("Did not get aircraft array")
                            }
                        })
                    } else {
                        print("Did not get icaoType array")
                    }
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
        completion()
    }
    
    func loadIcaoType(from jsonArray: NSArray, completion: @escaping (_ count: Int) -> Void) {
        let total       = jsonArray.count
        var count       = 0
        
        progressValue = 0.0
        for json in jsonArray {
            progressValue = Double(count / total)
            count += 1
            
            if let icaoTypeData = json as? [String: AnyObject] {
                count += 1
                
                let icaoTypeModel = IcaoType(icaoType: icaoTypeData["icao_type"] as? String ?? "",
                                             manufacturer: icaoTypeData["manufacturer"] as? String ?? "",
                                             model: icaoTypeData["model"] as? String ?? "",
                                             icon: icaoTypeData["icon"] as? String ?? "",
                                             altIcon: icaoTypeData["altIcon"] as? String ?? "",
                                             date: .now)

                modelContext.insert(icaoTypeModel)
            }
        }
        completion(count)
    }
  
    func loadAircraft(from jsonArray: NSArray, completion: @escaping (_ count: Int) -> Void) {
        let total       = jsonArray.count
        var count       = 0
        
        progressValue = 0.0
        for json in jsonArray {
            progressValue = Double(count / total)
            count += 1
        }
        completion(count)
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
