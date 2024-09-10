//
//  Notam.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/8/24.
//

import Foundation
import CoreImage
import CoreLocation

struct NotamData: Decodable {
    let totalCount: Int
    let notamItems: [NotamItems]?
}

struct NotamItems: Decodable {
    let properties: Property
    let geometry: Geometry
}

struct Property: Decodable {
    let coreNOTAMData: CoreNOTAMData
}

struct CoreNOTAMData: Decodable {
    let notam: Notam
    var notamTranslation: [NotamTranslation]?
}

struct Notam: Decodable {
    let id: String
    let number: String
    let type: String
    let issued: String
    let location: String
    let effectiveStart: String
    let effectiveEnd: String
    let text: String
    let classification: String
    let accountId: String
    let lastUpdated: String
    let icaoLocation: String
    var schedule: String?
    var coordinates: String?
   
}

struct NotamTranslation: Decodable {
    let type: String?
    let simpleText: String?
}

struct Geometry: Decodable {
    let type: String?
    var geometries: [Geometries]?
}

struct Geometries: Decodable {
    let type: String
    var heightInformation: HeightInformation?
    var subType: String?
    var additionalGeometryData: AdditionalGeometryData?
    var operation: String?
    var coordinates: [[CLLocationCoordinate2D]]?
    
    enum CodingKeys:String, CodingKey{
        case type
        case heightInformation
        case subType
        case additionalGeometryData
        case operation
        case coordinates
    }
    init(from decoder: Decoder) throws {
        let container           = try decoder.container(keyedBy: CodingKeys.self)
        type                    = try container.decodeIfPresent(String.self, forKey: .type) ?? "Unknowm"
        heightInformation       = try container.decodeIfPresent(HeightInformation.self, forKey: .heightInformation)
        additionalGeometryData  = try container.decodeIfPresent(AdditionalGeometryData.self, forKey: .additionalGeometryData)
        subType                 = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        operation               = try container.decodeIfPresent(String.self, forKey: .operation) ?? ""
        
        // print(type)
        var coords = try container.nestedUnkeyedContainer(forKey: .coordinates)
        if let count = coords.count {
            if count == 2 {  // a single array (Point)
                let lat = try coords.decode(CLLocationDegrees.self)
                let lon = try coords.decode(CLLocationDegrees.self)
                // print("  \(lat), \(lon)")
                var coordArray : [[CLLocationCoordinate2D]] = [[]]
                coordArray[0].append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
                coordinates = coordArray
            } else if count == 1 { // a multidimensional array (Polygon)
                coordinates = try container.decodeIfPresent([[CLLocationCoordinate2D]].self, forKey: .coordinates)?.map { $0.map() { ($0) } }
            }
        }
    }
}

struct AdditionalGeometryData: Decodable {
    let radius: String?
    let uomRadius: String?
}

struct HeightInformation: Decodable {
    let upperLevel: String
    let uomUpperLevel: String
    let lowerLevel: String
    let uomLowerLevel: String
}

extension CLLocationCoordinate2D : Decodable {
    public init(from decoder: Decoder) throws {
        var arrayContainer = try decoder.unkeyedContainer()
        let lat = try arrayContainer.decode(CLLocationDegrees.self)
        let lng = try arrayContainer.decode(CLLocationDegrees.self)
        self.init(latitude: lat, longitude: lng)
    }
}

/*
if let poly = decoder["polyline"].array {
     var polylines = [CGPoint]()

     for polyDecoder in poly {
         if let long = polyDecoder[0].float, let lat = polyDecoder[1].float {
             polylines.append(CGPointMake(long,lat)) //might want to double check if long or lat comes first (or specifically how they map to x and y)
         }
     }
     polyline = polylines
 }

*/


// https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types

// https://stackoverflow.com/questions/66183458/codable-mkpolygon

// https://www.andyibanez.com/posts/parsing-tricky-json-codable-swift/


/*
 
 {
     "type": "Feature",
     "properties": {
       "coreNOTAMData": {
         "notamEvent": {
           "scenario": "100005"
         },
         "notam": {
           "id": "NOTAM_1_65024257",
           "number": "2/7542",
        *  "type": "N",
           "issued": "2022-07-23T19:38:00.000Z",
        *  "selectionCode": "QXXXX",
           "location": "ZLC",
           "effectiveStart": "2022-07-24T13:00:00.000Z",
           "effectiveEnd": "2022-09-24T13:00:00.000Z",
           "text": "MT..AIRSPACE 16NM SOUTH OF ENNIS, MT..TEMPORARY\nFLIGHT RESTRICTIONS WI AN AREA DEFINED AS 5NM RADIUS OF\n450254N1115211W (DLN095031.2) SFC-12500FT. TO PROVIDE A SAFE\nENVIRONMENT FOR FIRE FIGHTING ACFT OPS. PURSUANT TO 14 CFR SECTION\n91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT. DILLON\nDISPATCH CENTER TELE 406-683-3975 OR FREQ 119.5750/CLOVER FIRE IS IN\nCHARGE OF THE OPERATION. SALT LAKE CITY /ZLC/ ARTCC TEL 801-320-2560\nIS THE FAA CDN FACILITY.",
        *  "classification": "FDC",
           "accountId": "FDC",
           "lastUpdated": "2022-07-23T19:39:00.000Z",
           "icaoLocation": "KZLC",
           "coordinates": "450254N1115211W"
         },
         "notamTranslation": [{
           "type": "LOCAL_FORMAT",
           "simpleText": "!FDC 2/7542 ZLC MT..AIRSPACE 16NM SOUTH OF ENNIS, MT..TEMPORARY\nFLIGHT RESTRICTIONS WI AN AREA DEFINED AS 5NM RADIUS OF\n450254N1115211W (DLN095031.2) SFC-12500FT. TO PROVIDE A SAFE\nENVIRONMENT FOR FIRE FIGHTING ACFT OPS. PURSUANT TO 14 CFR SECTION\n91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT. DILLON\nDISPATCH CENTER TELE 406-683-3975 OR FREQ 119.5750/CLOVER FIRE IS IN\nCHARGE OF THE OPERATION. SALT LAKE CITY /ZLC/ ARTCC TEL 801-320-2560\nIS THE FAA CDN FACILITY.\n\n2207241300-2209241300EST"
         }]
       }
     },
     "geometry": {
       "type": "GeometryCollection",
       "geometries": [{
         "type": "Polygon",
         "heightInformation": {
           "upperLevel": "12500",
           "uomUpperLevel": "FT",
           "lowerLevel": "0",
           "uomLowerLevel": "FT"
         },
         "coordinates": [
           [
             [-111.98726389, 45.04827285],
             [-111.985449, 45.03380565],
             [-111.98012046, 45.01978147],
             [-111.97144249, 45.00662596],
             [-111.95968047, 44.99473813],
             [-111.94519268, 44.98447829],
             [-111.92841932, 44.97615726],
             [-111.90986912, 44.97002698],
             [-111.89010401, 44.966273],
             [-111.86972222, 44.96500893],
             [-111.84934044, 44.966273],
             [-111.82957533, 44.97002698],
             [-111.81102513, 44.97615726],
             [-111.79425177, 44.98447829],
             [-111.77976398, 44.99473813],
             [-111.76800196, 45.00662596],
             [-111.75932398, 45.01978147],
             [-111.75399545, 45.03380565],
             [-111.75218055, 45.04827285],
             [-111.75393708, 45.06274366],
             [-111.75921429, 45.07677823],
             [-111.76785417, 45.08994967],
             [-111.77959592, 45.10185704],
             [-111.79408371, 45.11213768],
             [-111.81087734, 45.12047825],
             [-111.82946563, 45.12662446],
             [-111.84928207, 45.13038883],
             [-111.86972222, 45.13165652],
             [-111.89016237, 45.13038883],
             [-111.90997881, 45.12662446],
             [-111.92856711, 45.12047825],
             [-111.94536074, 45.11213768],
             [-111.95984853, 45.10185704],
             [-111.97159028, 45.08994967],
             [-111.98023015, 45.07677823],
             [-111.98550737, 45.06274366],
             [-111.98726389, 45.04827285]
           ]
         ]
       }]
     }
   }
*/

