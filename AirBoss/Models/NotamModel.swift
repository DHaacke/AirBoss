//
//  Notam.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/8/24.
//

import Foundation
import CoreImage
import CoreLocation

struct NotamModel: Decodable {
    let totalCount: Int
    let items: [Item]?
}

struct Item: Decodable {
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

struct Notam: Decodable, Identifiable {
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
        case items
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

extension CLLocationCoordinate2D : @retroactive Decodable {
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
     "pageSize": 50,
     "pageNum": 1,
     "totalCount": 28,
     "totalPages": 1,
     "items": [                    // items[0].properties.coreNOTAMData.notam.effectiveStart  items.properties.coreNOTAMDate.notam.id
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "101"
                     },
                     "notam": {
                         "id": "NOTAM_1_73170109",
                         "number": "4/8616",
                         "type": "N",
                         "issued": "2024-07-26T20:25:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-07-26T20:20:00.000Z",
                         "effectiveEnd": "2024-12-02T22:00:00.000Z",
                         "text": "AIRSPACE ADS-B, AUTO DEPENDENT SURVEILLANCE\nREBROADCAST (ADS-R), TFC INFO SER BCST (TIS-B), FLT INFO SER BCST\n(FIS-B) SER MAY NOT BE AVBL WI AN AREA DEFINED AS 107NM RADIUS OF\n410616N1070112W. AP AIRSPACE AFFECTED MAY INCLUDE RWL,\nCAG, DWX, HDN, RKS, SAA, SBS, 33V, 80V. SFC-13999FT.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-07-26T20:31:00.000Z",
                         "icaoLocation": "KZLC"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/8616 ZLC AIRSPACE ADS-B, AUTO DEPENDENT SURVEILLANCE\nREBROADCAST (ADS-R), TFC INFO SER BCST (TIS-B), FLT INFO SER BCST\n(FIS-B) SER MAY NOT BE AVBL WI AN AREA DEFINED AS 107NM RADIUS OF\n410616N1070112W. AP AIRSPACE AFFECTED MAY INCLUDE RWL,\nCAG, DWX, HDN, RKS, SAA, SBS, 33V, 80V. SFC-13999FT. \n2407262020-2412022200EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection"
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73537039",
                         "number": "4/8643",
                         "type": "N",
                         "issued": "2024-09-01T17:52:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-01T17:50:00.000Z",
                         "effectiveEnd": "2024-09-15T03:00:00.000Z",
                         "text": "WY..AIRSPACE 23NM NW DUBOIS, WY..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS\n434503N1101334W (DNW119006.6) TO\n433734N1100300W (DNW119017.4) TO\n433446N1100656W (DNW132017.7) TO\n434157N1101711W (DNW150008.0) TO POINT OF ORIGIN SFC-12000FT.  TO\nPROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING\nACFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT\nRESTRICTIONS ARE IN EFFECT. BRIDGER TETON NATIONAL FOREST TEL\n307-739-3630 OR FREQ 133.300/THE FISH CREEK SOUTH FIRE IS IN CHARGE\nOF THE OPS. SALT LAKE CITY /ZLC/ ARTCC TEL 801-320-2560\nIS THE FAA CDN FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-01T17:52:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "434503N1101334W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/8643 ZLC WY..AIRSPACE 23NM NW DUBOIS, WY..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS\n434503N1101334W (DNW119006.6) TO\n433734N1100300W (DNW119017.4) TO\n433446N1100656W (DNW132017.7) TO\n434157N1101711W (DNW150008.0) TO POINT OF ORIGIN SFC-12000FT.  TO\nPROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING\nACFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT\nRESTRICTIONS ARE IN EFFECT. BRIDGER TETON NATIONAL FOREST TEL\n307-739-3630 OR FREQ 133.300/THE FISH CREEK SOUTH FIRE IS IN CHARGE\nOF THE OPS. SALT LAKE CITY /ZLC/ ARTCC TEL 801-320-2560\nIS THE FAA CDN FACILITY. \n2409011750-2409150300EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "12000",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -110.22611111,
                                     43.75083333
                                 ],
                                 [
                                     -110.05,
                                     43.62611111
                                 ],
                                 [
                                     -110.11555556,
                                     43.57944444
                                 ],
                                 [
                                     -110.28638889,
                                     43.69916667
                                 ],
                                 [
                                     -110.22611111,
                                     43.75083333
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73537043",
                         "number": "4/8644",
                         "type": "N",
                         "issued": "2024-09-01T17:52:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-01T17:50:00.000Z",
                         "effectiveEnd": "2024-09-15T03:00:00.000Z",
                         "text": "WY..AIRSPACE 23NM NW DUBOIS, WY..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS 434933N1100705W (DNW076009.4) TO\n434230N1095610W (DNW098018.8) TO 433734N1100300W (DNW119017.4) TO\n434503N1101334W (DNW119006.6) TO POINT OF ORIGIN SFC-14000FT. TO\nPROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING ACFT OPS. PURSUANT TO\n14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN\nEFFECT. BRIDGER TETON NATIONAL FORESST TELEPHONE 307-739-3630 OR\nFREQ 133.300/THE FISH CREEK NORTH FIRE IS IN CHARGE OF THE\nOPERATION. SALT LAKE CITY /ZLC/ ARTCC TELEPHONE 801-320-2560\nIS THE FAA COORDINATION FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-01T17:53:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "434933N1100705W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/8644 ZLC WY..AIRSPACE 23NM NW DUBOIS, WY..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS 434933N1100705W (DNW076009.4) TO\n434230N1095610W (DNW098018.8) TO 433734N1100300W (DNW119017.4) TO\n434503N1101334W (DNW119006.6) TO POINT OF ORIGIN SFC-14000FT. TO\nPROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING ACFT OPS. PURSUANT TO\n14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN\nEFFECT. BRIDGER TETON NATIONAL FORESST TELEPHONE 307-739-3630 OR\nFREQ 133.300/THE FISH CREEK NORTH FIRE IS IN CHARGE OF THE\nOPERATION. SALT LAKE CITY /ZLC/ ARTCC TELEPHONE 801-320-2560\nIS THE FAA COORDINATION FACILITY. \n 2409011750-2409150300EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "14000",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -110.11805556,
                                     43.82583333
                                 ],
                                 [
                                     -109.93611111,
                                     43.70833333
                                 ],
                                 [
                                     -110.05,
                                     43.62611111
                                 ],
                                 [
                                     -110.22611111,
                                     43.75083333
                                 ],
                                 [
                                     -110.11805556,
                                     43.82583333
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73538683",
                         "number": "4/8694",
                         "type": "N",
                         "issued": "2024-09-02T02:31:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-02T14:00:00.000Z",
                         "effectiveEnd": "2024-09-16T14:00:00.000Z",
                         "text": "MT..AIRSPACE 23NM SE HAMILTON MT..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS \n460400N1134700W (CPN257043.3) TO\n455800N1132900W (CPN247031.0) TO\n454700N1133800W (CPN232040.0) TO\n455130N1135330W (CPN242049.0) TO POINT OF ORIGIN SFC-12000FT TO\nPROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING. PURSUANT TO 14 CFR\nSECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT.\nBITTERROOT DISPATCH TELEPHONE 406-363-7133 OR FREQ 124.2250/JOHNSON\nFIRE IS IN CHARGE OF THE OPERATION. SALT LAKE CITY /ZLC/ ARTCC\nTELEPHONE 801-320-2560 IS THE FAA COORDINATION FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-02T02:32:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "460400N1134700W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/8694 ZLC MT..AIRSPACE 23NM SE HAMILTON MT..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS \n460400N1134700W (CPN257043.3) TO\n455800N1132900W (CPN247031.0) TO\n454700N1133800W (CPN232040.0) TO\n455130N1135330W (CPN242049.0) TO POINT OF ORIGIN SFC-12000FT TO\nPROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING. PURSUANT TO 14 CFR\nSECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT.\nBITTERROOT DISPATCH TELEPHONE 406-363-7133 OR FREQ 124.2250/JOHNSON\nFIRE IS IN CHARGE OF THE OPERATION. SALT LAKE CITY /ZLC/ ARTCC\nTELEPHONE 801-320-2560 IS THE FAA COORDINATION FACILITY.\n2409021400-2409161400"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "12000",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -113.78333333,
                                     46.06666667
                                 ],
                                 [
                                     -113.48333333,
                                     45.96666667
                                 ],
                                 [
                                     -113.63333333,
                                     45.78333333
                                 ],
                                 [
                                     -113.89166667,
                                     45.85833333
                                 ],
                                 [
                                     -113.78333333,
                                     46.06666667
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73545898",
                         "number": "4/8931",
                         "type": "N",
                         "issued": "2024-09-03T02:21:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-03T14:00:00.000Z",
                         "effectiveEnd": "2024-09-16T03:00:00.000Z",
                         "text": "MT..AIRSPACE 26NM NW OF HELENA, MT..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 464900N1123200W\n(HLN286027.1) SFC-10000FT TO PROVIDE A SAFE ENVIRONMENT FOR\nFIREFIGHTING AIRCRAFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2)\nTEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT. HELENA DISPATCH\nTELEPHONE 406-444-4242 OR FREQ 118.4750/THE MARSH CREEK FIRE IS IN\nCHARGE OF THE OPERATION. ZLC SALT LAKE CITY /ZLC/ ARTCC TELEPHONE\n801-320-2560 IS THE FAA COORDINATION FACILITY. DLY 1400-0300",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-03T02:22:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "464900N1123200W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/8931 ZLC MT..AIRSPACE 26NM NW OF HELENA, MT..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 464900N1123200W\n(HLN286027.1) SFC-10000FT TO PROVIDE A SAFE ENVIRONMENT FOR\nFIREFIGHTING AIRCRAFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2)\nTEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT. HELENA DISPATCH\nTELEPHONE 406-444-4242 OR FREQ 118.4750/THE MARSH CREEK FIRE IS IN\nCHARGE OF THE OPERATION. ZLC SALT LAKE CITY /ZLC/ ARTCC TELEPHONE\n801-320-2560 IS THE FAA COORDINATION FACILITY. DLY 1400-0300\n2409031400-2409160300EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "10000",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -112.53333333,
                                     46.93328254
                                 ],
                                 [
                                     -112.50377219,
                                     46.93150708
                                 ],
                                 [
                                     -112.47511496,
                                     46.92623502
                                 ],
                                 [
                                     -112.44823738,
                                     46.91762752
                                 ],
                                 [
                                     -112.42395982,
                                     46.90594763
                                 ],
                                 [
                                     -112.4030219,
                                     46.89155207
                                 ],
                                 [
                                     -112.38605979,
                                     46.87488023
                                 ],
                                 [
                                     -112.37358685,
                                     46.8564405
                                 ],
                                 [
                                     -112.36597835,
                                     46.83679466
                                 ],
                                 [
                                     -112.36346044,
                                     46.81654061
                                 ],
                                 [
                                     -112.36610395,
                                     46.79629409
                                 ],
                                 [
                                     -112.37382291,
                                     46.77666994
                                 ],
                                 [
                                     -112.38637783,
                                     46.75826343
                                 ],
                                 [
                                     -112.40338357,
                                     46.74163233
                                 ],
                                 [
                                     -112.42432149,
                                     46.72728014
                                 ],
                                 [
                                     -112.44855542,
                                     46.71564099
                                 ],
                                 [
                                     -112.47535102,
                                     46.70706671
                                 ],
                                 [
                                     -112.5038978,
                                     46.70181633
                                 ],
                                 [
                                     -112.53333333,
                                     46.70004841
                                 ],
                                 [
                                     -112.56276887,
                                     46.70181633
                                 ],
                                 [
                                     -112.59131565,
                                     46.70706671
                                 ],
                                 [
                                     -112.61811124,
                                     46.71564099
                                 ],
                                 [
                                     -112.64234518,
                                     46.72728014
                                 ],
                                 [
                                     -112.6632831,
                                     46.74163233
                                 ],
                                 [
                                     -112.68028884,
                                     46.75826343
                                 ],
                                 [
                                     -112.69284375,
                                     46.77666994
                                 ],
                                 [
                                     -112.70056272,
                                     46.79629409
                                 ],
                                 [
                                     -112.70320623,
                                     46.81654061
                                 ],
                                 [
                                     -112.70068832,
                                     46.83679466
                                 ],
                                 [
                                     -112.69307981,
                                     46.8564405
                                 ],
                                 [
                                     -112.68060688,
                                     46.87488023
                                 ],
                                 [
                                     -112.66364476,
                                     46.89155207
                                 ],
                                 [
                                     -112.64270685,
                                     46.90594763
                                 ],
                                 [
                                     -112.61842929,
                                     46.91762752
                                 ],
                                 [
                                     -112.59155171,
                                     46.92623502
                                 ],
                                 [
                                     -112.56289447,
                                     46.93150708
                                 ],
                                 [
                                     -112.53333333,
                                     46.93328254
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73545993",
                         "number": "4/8933",
                         "type": "N",
                         "issued": "2024-09-03T02:50:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-03T14:00:00.000Z",
                         "effectiveEnd": "2024-09-17T03:00:00.000Z",
                         "text": "MT..AIRSPACE 8NM SE OF HAMILTON, MT..TEMPORARY\nFLIGHT RESTRICTIONS WI AN AREA DEFINED AS 5NM RADIUS OF\n461000N1135130W (MSO155045.5) SFC-10500FT.  TO\nPROVIDE A SAFE ENVIRONMENT FOR FIREFIGHTING AIRCRAFT OPS. PURSUANT\nTO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN\nEFFECT. BITTERROOT DISPATCH TELEPHONE 406-363-7133 OR FREQ\n120.7250/THE DALY FIRE IS IN CHARGE OF THE OPERATION. ZLC SALT LAKE\nCITY /ZLC/ ARTCC TELEPHONE 801-320-2560 IS THE FAA COORDINATION\nFACILITY. \nDLY 1400-0300",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-03T02:50:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "461000N1135130W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/8933 ZLC MT..AIRSPACE 8NM SE OF HAMILTON, MT..TEMPORARY\nFLIGHT RESTRICTIONS WI AN AREA DEFINED AS 5NM RADIUS OF\n461000N1135130W (MSO155045.5) SFC-10500FT.  TO\nPROVIDE A SAFE ENVIRONMENT FOR FIREFIGHTING AIRCRAFT OPS. PURSUANT\nTO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN\nEFFECT. BITTERROOT DISPATCH TELEPHONE 406-363-7133 OR FREQ\n120.7250/THE DALY FIRE IS IN CHARGE OF THE OPERATION. ZLC SALT LAKE\nCITY /ZLC/ ARTCC TELEPHONE 801-320-2560 IS THE FAA COORDINATION\nFACILITY. \nDLY 1400-0300 \n2409031400-2409170300EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "10500",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -113.85833333,
                                     46.24997347
                                 ],
                                 [
                                     -113.83748173,
                                     46.24870596
                                 ],
                                 [
                                     -113.8172665,
                                     46.24494212
                                 ],
                                 [
                                     -113.79830434,
                                     46.2387968
                                 ],
                                 [
                                     -113.78117323,
                                     46.23045747
                                 ],
                                 [
                                     -113.76639465,
                                     46.22017844
                                 ],
                                 [
                                     -113.75441764,
                                     46.20827302
                                 ],
                                 [
                                     -113.74560512,
                                     46.19510385
                                 ],
                                 [
                                     -113.74022303,
                                     46.18107183
                                 ],
                                 [
                                     -113.73843243,
                                     46.16660379
                                 ],
                                 [
                                     -113.74028494,
                                     46.15213951
                                 ],
                                 [
                                     -113.74572147,
                                     46.1381183
                                 ],
                                 [
                                     -113.75457439,
                                     46.12496569
                                 ],
                                 [
                                     -113.7665729,
                                     46.11308059
                                 ],
                                 [
                                     -113.78135148,
                                     46.10282319
                                 ],
                                 [
                                     -113.79846109,
                                     46.09450418
                                 ],
                                 [
                                     -113.81738285,
                                     46.08837543
                                 ],
                                 [
                                     -113.83754364,
                                     46.0846224
                                 ],
                                 [
                                     -113.85833333,
                                     46.08335864
                                 ],
                                 [
                                     -113.87912303,
                                     46.0846224
                                 ],
                                 [
                                     -113.89928382,
                                     46.08837543
                                 ],
                                 [
                                     -113.91820558,
                                     46.09450418
                                 ],
                                 [
                                     -113.93531519,
                                     46.10282319
                                 ],
                                 [
                                     -113.95009377,
                                     46.11308059
                                 ],
                                 [
                                     -113.96209228,
                                     46.12496569
                                 ],
                                 [
                                     -113.9709452,
                                     46.1381183
                                 ],
                                 [
                                     -113.97638173,
                                     46.15213951
                                 ],
                                 [
                                     -113.97823423,
                                     46.16660379
                                 ],
                                 [
                                     -113.97644363,
                                     46.18107183
                                 ],
                                 [
                                     -113.97106154,
                                     46.19510385
                                 ],
                                 [
                                     -113.96224903,
                                     46.20827302
                                 ],
                                 [
                                     -113.95027202,
                                     46.22017844
                                 ],
                                 [
                                     -113.93549344,
                                     46.23045747
                                 ],
                                 [
                                     -113.91836233,
                                     46.2387968
                                 ],
                                 [
                                     -113.89940016,
                                     46.24494212
                                 ],
                                 [
                                     -113.87918493,
                                     46.24870596
                                 ],
                                 [
                                     -113.85833333,
                                     46.24997347
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73546041",
                         "number": "4/8937",
                         "type": "N",
                         "issued": "2024-09-03T03:07:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-03T15:00:00.000Z",
                         "effectiveEnd": "2024-09-16T04:00:00.000Z",
                         "text": "ID..AIRSPACE 23NM SE MCCALL, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS\n444630N1155100W (DNJ069015.2) TO\n444630N1153900W (DNJ070023.8) TO\n443000N1153900W (DNJ105028.7) TO\n442300N1154600W (DNJ122029.8) TO\n442300N1155530W (DNJ133026.0) TO\n443000N1155530W (DNJ124020.1) TO POINT OF ORIGIN\nSFC-11500FT.  TO PROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING\nACFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT\nRESTRICTIONS ARE IN EFFECT. BOISE NATIONAL FORET TELEPHONE\n208-384-3398 OR FREQ 126.075/THE SNAG DAY FIRE IS IN CHARGE OF THE\nOPERATION. ZLC SALT LAKE CITY /ZLC/ ARTCC TELEPHONE 801-320-2560 IS\nTHE FAA COORDINATION FACILITY. \nDLY 1500-0400",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-03T03:07:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "444630N1155100W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/8937 ZLC ID..AIRSPACE 23NM SE MCCALL, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS\n444630N1155100W (DNJ069015.2) TO\n444630N1153900W (DNJ070023.8) TO\n443000N1153900W (DNJ105028.7) TO\n442300N1154600W (DNJ122029.8) TO\n442300N1155530W (DNJ133026.0) TO\n443000N1155530W (DNJ124020.1) TO POINT OF ORIGIN\nSFC-11500FT.  TO PROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING\nACFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT\nRESTRICTIONS ARE IN EFFECT. BOISE NATIONAL FORET TELEPHONE\n208-384-3398 OR FREQ 126.075/THE SNAG DAY FIRE IS IN CHARGE OF THE\nOPERATION. ZLC SALT LAKE CITY /ZLC/ ARTCC TELEPHONE 801-320-2560 IS\nTHE FAA COORDINATION FACILITY. \nDLY 1500-0400 \n2409031500-2409160400EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "11500",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -115.85,
                                     44.775
                                 ],
                                 [
                                     -115.65,
                                     44.775
                                 ],
                                 [
                                     -115.65,
                                     44.5
                                 ],
                                 [
                                     -115.76666667,
                                     44.38333333
                                 ],
                                 [
                                     -115.925,
                                     44.38333333
                                 ],
                                 [
                                     -115.925,
                                     44.5
                                 ],
                                 [
                                     -115.85,
                                     44.775
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73546062",
                         "number": "4/8938",
                         "type": "N",
                         "issued": "2024-09-03T03:15:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-03T04:00:00.000Z",
                         "effectiveEnd": "2024-09-16T15:00:00.000Z",
                         "text": "ID..AIRSPACE 23NM SE MCCALL, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS\n444630N1155100W (DNJ069015.2) TO\n444630N1153900W (DNJ070023.8) TO\n443000N1153900W (DNJ105028.7) TO\n442300N1154600W (DNJ122029.8) TO\n442300N1155530W (DNJ133026.0) TO\n443000N1155530W (DNJ124020.1) TO POINT OF ORIGIN\nSFC-8500FT.  TO PROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING\nACFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT\nRESTRICTIONS ARE IN EFFECT. BOISE NATIONAL FOREST TELEPHONE\n208-384-3398 OR FREQ 126.075/THE SNAG NIGHT FIRE IS IN CHARGE OF THE\nOPERATION. ZLC SALT LAKE CITY /ZLC/ ARTCC TELEPHONE 801-320-2560 IS\nTHE FAA COORDINATION FACILITY. \nDLY 0400-1500",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-03T03:15:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "444630N1155100W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/8938 ZLC ID..AIRSPACE 23NM SE MCCALL, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS\n444630N1155100W (DNJ069015.2) TO\n444630N1153900W (DNJ070023.8) TO\n443000N1153900W (DNJ105028.7) TO\n442300N1154600W (DNJ122029.8) TO\n442300N1155530W (DNJ133026.0) TO\n443000N1155530W (DNJ124020.1) TO POINT OF ORIGIN\nSFC-8500FT.  TO PROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING\nACFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT\nRESTRICTIONS ARE IN EFFECT. BOISE NATIONAL FOREST TELEPHONE\n208-384-3398 OR FREQ 126.075/THE SNAG NIGHT FIRE IS IN CHARGE OF THE\nOPERATION. ZLC SALT LAKE CITY /ZLC/ ARTCC TELEPHONE 801-320-2560 IS\nTHE FAA COORDINATION FACILITY. \nDLY 0400-1500 \n2409030400-2409161500EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "8500",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -115.85,
                                     44.775
                                 ],
                                 [
                                     -115.65,
                                     44.775
                                 ],
                                 [
                                     -115.65,
                                     44.5
                                 ],
                                 [
                                     -115.76666667,
                                     44.38333333
                                 ],
                                 [
                                     -115.925,
                                     44.38333333
                                 ],
                                 [
                                     -115.925,
                                     44.5
                                 ],
                                 [
                                     -115.85,
                                     44.775
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73557310",
                         "number": "4/9608",
                         "type": "N",
                         "issued": "2024-09-04T03:46:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-04T15:00:00.000Z",
                         "effectiveEnd": "2024-09-19T03:00:00.000Z",
                         "text": "ID..AIRSPACE 32NM WEST OF HAILEY, ID..TEMPORARY\nFLIGHT RESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF\n432824N1150221W (BOI078050.6) SFC-13000FT. TO PROVIDE A SAFE\nENVIRONMENT FOR FIRE FIGHTING ACFT OPS. PURSUANT TO 14 CFR SECTION\n91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT. SOUTH\nIDAHO DISPATCH TEL 208-732-7265 OR FREQ 121.300/THE CHIMNEY FIRE IS\nIN CHARGE OF THE OPS. SALT LAKE CITY /ZLC/ ARTCC TEL 801-320-2560 IS\nTHE FAA CDN FACILITY.\nDLY 1500-0300",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-04T03:47:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "432824N1150221W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/9608 ZLC ID..AIRSPACE 32NM WEST OF HAILEY, ID..TEMPORARY\nFLIGHT RESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF\n432824N1150221W (BOI078050.6) SFC-13000FT. TO PROVIDE A SAFE\nENVIRONMENT FOR FIRE FIGHTING ACFT OPS. PURSUANT TO 14 CFR SECTION\n91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT. SOUTH\nIDAHO DISPATCH TEL 208-732-7265 OR FREQ 121.300/THE CHIMNEY FIRE IS\nIN CHARGE OF THE OPS. SALT LAKE CITY /ZLC/ ARTCC TEL 801-320-2560 IS\nTHE FAA CDN FACILITY.\nDLY 1500-0300 \n2409041500-2409190300EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "13000",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -115.03916667,
                                     43.59001774
                                 ],
                                 [
                                     -115.01129139,
                                     43.58824167
                                 ],
                                 [
                                     -114.98426788,
                                     43.58296772
                                 ],
                                 [
                                     -114.95892144,
                                     43.57435701
                                 ],
                                 [
                                     -114.93602531,
                                     43.56267252
                                 ],
                                 [
                                     -114.91627682,
                                     43.54827092
                                 ],
                                 [
                                     -114.90027601,
                                     43.53159154
                                 ],
                                 [
                                     -114.88850736,
                                     43.51314281
                                 ],
                                 [
                                     -114.88132533,
                                     43.49348663
                                 ],
                                 [
                                     -114.87894393,
                                     43.47322108
                                 ],
                                 [
                                     -114.88143076,
                                     43.45296224
                                 ],
                                 [
                                     -114.88870551,
                                     43.43332533
                                 ],
                                 [
                                     -114.90054297,
                                     43.41490615
                                 ],
                                 [
                                     -114.9165804,
                                     43.39826302
                                 ],
                                 [
                                     -114.93632889,
                                     43.38389999
                                 ],
                                 [
                                     -114.95918841,
                                     43.37225174
                                 ],
                                 [
                                     -114.98446603,
                                     43.36367058
                                 ],
                                 [
                                     -115.01139683,
                                     43.35841591
                                 ],
                                 [
                                     -115.03916667,
                                     43.35664653
                                 ],
                                 [
                                     -115.06693651,
                                     43.35841591
                                 ],
                                 [
                                     -115.0938673,
                                     43.36367058
                                 ],
                                 [
                                     -115.11914493,
                                     43.37225174
                                 ],
                                 [
                                     -115.14200444,
                                     43.38389999
                                 ],
                                 [
                                     -115.16175293,
                                     43.39826302
                                 ],
                                 [
                                     -115.17779036,
                                     43.41490615
                                 ],
                                 [
                                     -115.18962782,
                                     43.43332533
                                 ],
                                 [
                                     -115.19690257,
                                     43.45296224
                                 ],
                                 [
                                     -115.1993894,
                                     43.47322108
                                 ],
                                 [
                                     -115.197008,
                                     43.49348663
                                 ],
                                 [
                                     -115.18982597,
                                     43.51314281
                                 ],
                                 [
                                     -115.17805732,
                                     43.53159154
                                 ],
                                 [
                                     -115.16205651,
                                     43.54827092
                                 ],
                                 [
                                     -115.14230803,
                                     43.56267252
                                 ],
                                 [
                                     -115.11941189,
                                     43.57435701
                                 ],
                                 [
                                     -115.09406545,
                                     43.58296772
                                 ],
                                 [
                                     -115.06704194,
                                     43.58824167
                                 ],
                                 [
                                     -115.03916667,
                                     43.59001774
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73565429",
                         "number": "4/0052",
                         "type": "N",
                         "issued": "2024-09-04T18:08:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-04T18:15:00.000Z",
                         "effectiveEnd": "2024-09-19T03:00:00.000Z",
                         "text": "ID..AIRSPACE GARDEN VALLEY, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS\n442200N1154100W (DNJ118032.9) TO\n442200N1153000W (DNJ109038.7) TO\n441400N1153000W (DNJ118044.1) TO\n440300N1154100W (DNJ133048.6) TO\n440300N1155400W (DNJ144045.0) TO\n441300N1155700W (DNJ143034.8) TO\n442000N1154930W (DNJ129030.7) TO POINT OF ORIGIN. SFC-11000FT. \nTO PROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING\nACFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT\nRESTRICTIONS ARE IN EFFECT. BOISE NATIONAL FOREST TEL\n208-384-3398 OR FREQ 123.600/THE MIDDLEFORK FIRE IS IN CHARGE OF THE\nOPS. ZLC SALT LAKE CITY /ZLC/ ARTCC TEL 801-320-2560 IS\nTHE FAA CDN FAC.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-04T18:08:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "442200N1154100W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/0052 ZLC ID..AIRSPACE GARDEN VALLEY, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS\n442200N1154100W (DNJ118032.9) TO\n442200N1153000W (DNJ109038.7) TO\n441400N1153000W (DNJ118044.1) TO\n440300N1154100W (DNJ133048.6) TO\n440300N1155400W (DNJ144045.0) TO\n441300N1155700W (DNJ143034.8) TO\n442000N1154930W (DNJ129030.7) TO POINT OF ORIGIN. SFC-11000FT. \nTO PROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING\nACFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT\nRESTRICTIONS ARE IN EFFECT. BOISE NATIONAL FOREST TEL\n208-384-3398 OR FREQ 123.600/THE MIDDLEFORK FIRE IS IN CHARGE OF THE\nOPS. ZLC SALT LAKE CITY /ZLC/ ARTCC TEL 801-320-2560 IS\nTHE FAA CDN FAC.\n2409041815-2409190300EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "11000",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -115.95,
                                     44.21666667
                                 ],
                                 [
                                     -115.9,
                                     44.05
                                 ],
                                 [
                                     -115.68333333,
                                     44.05
                                 ],
                                 [
                                     -115.5,
                                     44.23333333
                                 ],
                                 [
                                     -115.5,
                                     44.36666667
                                 ],
                                 [
                                     -115.68333333,
                                     44.36666667
                                 ],
                                 [
                                     -115.825,
                                     44.33333333
                                 ],
                                 [
                                     -115.95,
                                     44.21666667
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73569844",
                         "number": "4/0520",
                         "type": "N",
                         "issued": "2024-09-05T03:15:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-05T15:00:00.000Z",
                         "effectiveEnd": "2024-09-20T03:00:00.000Z",
                         "text": "ID..AIRSPACE 25NM SW OF SALMON, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 445930N1142530W\n(LKT250014.6) SFC-12500FT. TO PROVIDE A SAFE ENVIRONMENT FOR FIRE\nFIGHTING ACFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY\nFLIGHT RESTRICTIONS ARE IN EFFECT. CENTRAL IDAHO DISPATCH TEL\n208-756-5157 OR FREQ 132.125/THE RED ROCK FIRE IS IN CHARGE OF THE\nOPS. SALT LAKE CITY /ZLC/ ARTCC TEL 801-320-2560 IS THE FAA CDN\nFACILITY. DLY 1500-0300",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-05T03:15:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "445930N1142530W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/0520 ZLC ID..AIRSPACE 25NM SW OF SALMON, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 445930N1142530W\n(LKT250014.6) SFC-12500FT. TO PROVIDE A SAFE ENVIRONMENT FOR FIRE\nFIGHTING ACFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY\nFLIGHT RESTRICTIONS ARE IN EFFECT. CENTRAL IDAHO DISPATCH TEL\n208-756-5157 OR FREQ 132.125/THE RED ROCK FIRE IS IN CHARGE OF THE\nOPS. SALT LAKE CITY /ZLC/ ARTCC TEL 801-320-2560 IS THE FAA CDN\nFACILITY. DLY 1500-0300\n2409051500-2409200300EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "12500",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -114.425,
                                     45.10831994
                                 ],
                                 [
                                     -114.39639572,
                                     45.10654416
                                 ],
                                 [
                                     -114.36866574,
                                     45.10127108
                                 ],
                                 [
                                     -114.34265718,
                                     45.09266186
                                 ],
                                 [
                                     -114.31916366,
                                     45.08097949
                                 ],
                                 [
                                     -114.2989008,
                                     45.06658067
                                 ],
                                 [
                                     -114.28248425,
                                     45.04990474
                                 ],
                                 [
                                     -114.270411,
                                     45.03146013
                                 ],
                                 [
                                     -114.26304449,
                                     45.01180866
                                 ],
                                 [
                                     -114.26060401,
                                     44.99154835
                                 ],
                                 [
                                     -114.26315855,
                                     44.97129509
                                 ],
                                 [
                                     -114.27062536,
                                     44.95166396
                                 ],
                                 [
                                     -114.28277306,
                                     44.93325051
                                 ],
                                 [
                                     -114.29922922,
                                     44.91661281
                                 ],
                                 [
                                     -114.31949208,
                                     44.90225467
                                 ],
                                 [
                                     -114.34294599,
                                     44.89061052
                                 ],
                                 [
                                     -114.3688801,
                                     44.88203246
                                 ],
                                 [
                                     -114.39650978,
                                     44.87677972
                                 ],
                                 [
                                     -114.425,
                                     44.875011
                                 ],
                                 [
                                     -114.45349022,
                                     44.87677972
                                 ],
                                 [
                                     -114.4811199,
                                     44.88203246
                                 ],
                                 [
                                     -114.50705401,
                                     44.89061052
                                 ],
                                 [
                                     -114.53050792,
                                     44.90225467
                                 ],
                                 [
                                     -114.55077078,
                                     44.91661281
                                 ],
                                 [
                                     -114.56722694,
                                     44.93325051
                                 ],
                                 [
                                     -114.57937464,
                                     44.95166396
                                 ],
                                 [
                                     -114.58684145,
                                     44.97129509
                                 ],
                                 [
                                     -114.58939599,
                                     44.99154835
                                 ],
                                 [
                                     -114.58695551,
                                     45.01180866
                                 ],
                                 [
                                     -114.579589,
                                     45.03146013
                                 ],
                                 [
                                     -114.56751575,
                                     45.04990474
                                 ],
                                 [
                                     -114.5510992,
                                     45.06658067
                                 ],
                                 [
                                     -114.53083634,
                                     45.08097949
                                 ],
                                 [
                                     -114.50734282,
                                     45.09266186
                                 ],
                                 [
                                     -114.48133426,
                                     45.10127108
                                 ],
                                 [
                                     -114.45360428,
                                     45.10654416
                                 ],
                                 [
                                     -114.425,
                                     45.10831994
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73577306",
                         "number": "4/1082",
                         "type": "N",
                         "issued": "2024-09-05T16:01:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-09T14:00:00.000Z",
                         "effectiveEnd": "2024-09-10T06:00:00.000Z",
                         "text": "NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-05T16:03:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "405259N1190205W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/1082 ZLC NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.\n\n2409091400-2409100600"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "910",
                             "uomUpperLevel": "FL",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -119.03472222,
                                     40.99979284
                                 ],
                                 [
                                     -119.0079664,
                                     40.99801626
                                 ],
                                 [
                                     -118.98202774,
                                     40.99274076
                                 ],
                                 [
                                     -118.95769805,
                                     40.98412745
                                 ],
                                 [
                                     -118.93571931,
                                     40.97243926
                                 ],
                                 [
                                     -118.91676078,
                                     40.95803283
                                 ],
                                 [
                                     -118.90139848,
                                     40.94134748
                                 ],
                                 [
                                     -118.89009771,
                                     40.92289169
                                 ],
                                 [
                                     -118.8831991,
                                     40.90322743
                                 ],
                                 [
                                     -118.88090857,
                                     40.882953
                                 ],
                                 [
                                     -118.88329153,
                                     40.86268467
                                 ],
                                 [
                                     -118.89027143,
                                     40.84303802
                                 ],
                                 [
                                     -118.90163253,
                                     40.8246092
                                 ],
                                 [
                                     -118.91702694,
                                     40.80795693
                                 ],
                                 [
                                     -118.93598547,
                                     40.79358571
                                 ],
                                 [
                                     -118.95793211,
                                     40.7819306
                                 ],
                                 [
                                     -118.98220146,
                                     40.77334426
                                 ],
                                 [
                                     -119.00805884,
                                     40.76808637
                                 ],
                                 [
                                     -119.03472222,
                                     40.7663159
                                 ],
                                 [
                                     -119.06138561,
                                     40.76808637
                                 ],
                                 [
                                     -119.08724298,
                                     40.77334426
                                 ],
                                 [
                                     -119.11151234,
                                     40.7819306
                                 ],
                                 [
                                     -119.13345897,
                                     40.79358571
                                 ],
                                 [
                                     -119.15241751,
                                     40.80795693
                                 ],
                                 [
                                     -119.16781191,
                                     40.8246092
                                 ],
                                 [
                                     -119.17917301,
                                     40.84303802
                                 ],
                                 [
                                     -119.18615291,
                                     40.86268467
                                 ],
                                 [
                                     -119.18853588,
                                     40.882953
                                 ],
                                 [
                                     -119.18624535,
                                     40.90322743
                                 ],
                                 [
                                     -119.17934673,
                                     40.92289169
                                 ],
                                 [
                                     -119.16804597,
                                     40.94134748
                                 ],
                                 [
                                     -119.15268367,
                                     40.95803283
                                 ],
                                 [
                                     -119.13372513,
                                     40.97243926
                                 ],
                                 [
                                     -119.1117464,
                                     40.98412745
                                 ],
                                 [
                                     -119.08741671,
                                     40.99274076
                                 ],
                                 [
                                     -119.06147804,
                                     40.99801626
                                 ],
                                 [
                                     -119.03472222,
                                     40.99979284
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73577307",
                         "number": "4/1083",
                         "type": "N",
                         "issued": "2024-09-05T16:01:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-10T14:00:00.000Z",
                         "effectiveEnd": "2024-09-11T06:00:00.000Z",
                         "text": "NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-05T16:03:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "405259N1190205W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/1083 ZLC NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.\n\n2409101400-2409110600"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "910",
                             "uomUpperLevel": "FL",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -119.18853588,
                                     40.882953
                                 ],
                                 [
                                     -119.18615291,
                                     40.86268467
                                 ],
                                 [
                                     -119.17917301,
                                     40.84303802
                                 ],
                                 [
                                     -119.16781191,
                                     40.8246092
                                 ],
                                 [
                                     -119.15241751,
                                     40.80795693
                                 ],
                                 [
                                     -119.13345897,
                                     40.79358571
                                 ],
                                 [
                                     -119.11151234,
                                     40.7819306
                                 ],
                                 [
                                     -119.08724298,
                                     40.77334426
                                 ],
                                 [
                                     -119.06138561,
                                     40.76808637
                                 ],
                                 [
                                     -119.03472222,
                                     40.7663159
                                 ],
                                 [
                                     -119.00805884,
                                     40.76808637
                                 ],
                                 [
                                     -118.98220146,
                                     40.77334426
                                 ],
                                 [
                                     -118.95793211,
                                     40.7819306
                                 ],
                                 [
                                     -118.93598547,
                                     40.79358571
                                 ],
                                 [
                                     -118.91702694,
                                     40.80795693
                                 ],
                                 [
                                     -118.90163253,
                                     40.8246092
                                 ],
                                 [
                                     -118.89027143,
                                     40.84303802
                                 ],
                                 [
                                     -118.88329153,
                                     40.86268467
                                 ],
                                 [
                                     -118.88090857,
                                     40.882953
                                 ],
                                 [
                                     -118.8831991,
                                     40.90322743
                                 ],
                                 [
                                     -118.89009771,
                                     40.92289169
                                 ],
                                 [
                                     -118.90139848,
                                     40.94134748
                                 ],
                                 [
                                     -118.91676078,
                                     40.95803283
                                 ],
                                 [
                                     -118.93571931,
                                     40.97243926
                                 ],
                                 [
                                     -118.95769805,
                                     40.98412745
                                 ],
                                 [
                                     -118.98202774,
                                     40.99274076
                                 ],
                                 [
                                     -119.0079664,
                                     40.99801626
                                 ],
                                 [
                                     -119.03472222,
                                     40.99979284
                                 ],
                                 [
                                     -119.06147804,
                                     40.99801626
                                 ],
                                 [
                                     -119.08741671,
                                     40.99274076
                                 ],
                                 [
                                     -119.1117464,
                                     40.98412745
                                 ],
                                 [
                                     -119.13372513,
                                     40.97243926
                                 ],
                                 [
                                     -119.15268367,
                                     40.95803283
                                 ],
                                 [
                                     -119.16804597,
                                     40.94134748
                                 ],
                                 [
                                     -119.17934673,
                                     40.92289169
                                 ],
                                 [
                                     -119.18624535,
                                     40.90322743
                                 ],
                                 [
                                     -119.18853588,
                                     40.882953
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73577327",
                         "number": "4/1084",
                         "type": "N",
                         "issued": "2024-09-05T16:03:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-11T14:00:00.000Z",
                         "effectiveEnd": "2024-09-12T06:00:00.000Z",
                         "text": "NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-05T16:04:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "405259N1190205W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/1084 ZLC NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.\n\n2409111400-2409120600"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "910",
                             "uomUpperLevel": "FL",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -119.03472222,
                                     40.99979284
                                 ],
                                 [
                                     -119.0079664,
                                     40.99801626
                                 ],
                                 [
                                     -118.98202774,
                                     40.99274076
                                 ],
                                 [
                                     -118.95769805,
                                     40.98412745
                                 ],
                                 [
                                     -118.93571931,
                                     40.97243926
                                 ],
                                 [
                                     -118.91676078,
                                     40.95803283
                                 ],
                                 [
                                     -118.90139848,
                                     40.94134748
                                 ],
                                 [
                                     -118.89009771,
                                     40.92289169
                                 ],
                                 [
                                     -118.8831991,
                                     40.90322743
                                 ],
                                 [
                                     -118.88090857,
                                     40.882953
                                 ],
                                 [
                                     -118.88329153,
                                     40.86268467
                                 ],
                                 [
                                     -118.89027143,
                                     40.84303802
                                 ],
                                 [
                                     -118.90163253,
                                     40.8246092
                                 ],
                                 [
                                     -118.91702694,
                                     40.80795693
                                 ],
                                 [
                                     -118.93598547,
                                     40.79358571
                                 ],
                                 [
                                     -118.95793211,
                                     40.7819306
                                 ],
                                 [
                                     -118.98220146,
                                     40.77334426
                                 ],
                                 [
                                     -119.00805884,
                                     40.76808637
                                 ],
                                 [
                                     -119.03472222,
                                     40.7663159
                                 ],
                                 [
                                     -119.06138561,
                                     40.76808637
                                 ],
                                 [
                                     -119.08724298,
                                     40.77334426
                                 ],
                                 [
                                     -119.11151234,
                                     40.7819306
                                 ],
                                 [
                                     -119.13345897,
                                     40.79358571
                                 ],
                                 [
                                     -119.15241751,
                                     40.80795693
                                 ],
                                 [
                                     -119.16781191,
                                     40.8246092
                                 ],
                                 [
                                     -119.17917301,
                                     40.84303802
                                 ],
                                 [
                                     -119.18615291,
                                     40.86268467
                                 ],
                                 [
                                     -119.18853588,
                                     40.882953
                                 ],
                                 [
                                     -119.18624535,
                                     40.90322743
                                 ],
                                 [
                                     -119.17934673,
                                     40.92289169
                                 ],
                                 [
                                     -119.16804597,
                                     40.94134748
                                 ],
                                 [
                                     -119.15268367,
                                     40.95803283
                                 ],
                                 [
                                     -119.13372513,
                                     40.97243926
                                 ],
                                 [
                                     -119.1117464,
                                     40.98412745
                                 ],
                                 [
                                     -119.08741671,
                                     40.99274076
                                 ],
                                 [
                                     -119.06147804,
                                     40.99801626
                                 ],
                                 [
                                     -119.03472222,
                                     40.99979284
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73577344",
                         "number": "4/1085",
                         "type": "N",
                         "issued": "2024-09-05T16:03:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-12T14:00:00.000Z",
                         "effectiveEnd": "2024-09-13T06:00:00.000Z",
                         "text": "NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-05T16:05:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "405259N1190205W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/1085 ZLC NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.\n\n2409121400-2409130600"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "910",
                             "uomUpperLevel": "FL",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -119.03472222,
                                     40.99979284
                                 ],
                                 [
                                     -119.0079664,
                                     40.99801626
                                 ],
                                 [
                                     -118.98202774,
                                     40.99274076
                                 ],
                                 [
                                     -118.95769805,
                                     40.98412745
                                 ],
                                 [
                                     -118.93571931,
                                     40.97243926
                                 ],
                                 [
                                     -118.91676078,
                                     40.95803283
                                 ],
                                 [
                                     -118.90139848,
                                     40.94134748
                                 ],
                                 [
                                     -118.89009771,
                                     40.92289169
                                 ],
                                 [
                                     -118.8831991,
                                     40.90322743
                                 ],
                                 [
                                     -118.88090857,
                                     40.882953
                                 ],
                                 [
                                     -118.88329153,
                                     40.86268467
                                 ],
                                 [
                                     -118.89027143,
                                     40.84303802
                                 ],
                                 [
                                     -118.90163253,
                                     40.8246092
                                 ],
                                 [
                                     -118.91702694,
                                     40.80795693
                                 ],
                                 [
                                     -118.93598547,
                                     40.79358571
                                 ],
                                 [
                                     -118.95793211,
                                     40.7819306
                                 ],
                                 [
                                     -118.98220146,
                                     40.77334426
                                 ],
                                 [
                                     -119.00805884,
                                     40.76808637
                                 ],
                                 [
                                     -119.03472222,
                                     40.7663159
                                 ],
                                 [
                                     -119.06138561,
                                     40.76808637
                                 ],
                                 [
                                     -119.08724298,
                                     40.77334426
                                 ],
                                 [
                                     -119.11151234,
                                     40.7819306
                                 ],
                                 [
                                     -119.13345897,
                                     40.79358571
                                 ],
                                 [
                                     -119.15241751,
                                     40.80795693
                                 ],
                                 [
                                     -119.16781191,
                                     40.8246092
                                 ],
                                 [
                                     -119.17917301,
                                     40.84303802
                                 ],
                                 [
                                     -119.18615291,
                                     40.86268467
                                 ],
                                 [
                                     -119.18853588,
                                     40.882953
                                 ],
                                 [
                                     -119.18624535,
                                     40.90322743
                                 ],
                                 [
                                     -119.17934673,
                                     40.92289169
                                 ],
                                 [
                                     -119.16804597,
                                     40.94134748
                                 ],
                                 [
                                     -119.15268367,
                                     40.95803283
                                 ],
                                 [
                                     -119.13372513,
                                     40.97243926
                                 ],
                                 [
                                     -119.1117464,
                                     40.98412745
                                 ],
                                 [
                                     -119.08741671,
                                     40.99274076
                                 ],
                                 [
                                     -119.06147804,
                                     40.99801626
                                 ],
                                 [
                                     -119.03472222,
                                     40.99979284
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73577345",
                         "number": "4/1086",
                         "type": "N",
                         "issued": "2024-09-05T16:04:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-13T14:00:00.000Z",
                         "effectiveEnd": "2024-09-14T06:00:00.000Z",
                         "text": "NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-05T16:04:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "405259N1190205W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/1086 ZLC NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.\n\n2409131400-2409140600"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "910",
                             "uomUpperLevel": "FL",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -119.03472222,
                                     40.99979284
                                 ],
                                 [
                                     -119.0079664,
                                     40.99801626
                                 ],
                                 [
                                     -118.98202774,
                                     40.99274076
                                 ],
                                 [
                                     -118.95769805,
                                     40.98412745
                                 ],
                                 [
                                     -118.93571931,
                                     40.97243926
                                 ],
                                 [
                                     -118.91676078,
                                     40.95803283
                                 ],
                                 [
                                     -118.90139848,
                                     40.94134748
                                 ],
                                 [
                                     -118.89009771,
                                     40.92289169
                                 ],
                                 [
                                     -118.8831991,
                                     40.90322743
                                 ],
                                 [
                                     -118.88090857,
                                     40.882953
                                 ],
                                 [
                                     -118.88329153,
                                     40.86268467
                                 ],
                                 [
                                     -118.89027143,
                                     40.84303802
                                 ],
                                 [
                                     -118.90163253,
                                     40.8246092
                                 ],
                                 [
                                     -118.91702694,
                                     40.80795693
                                 ],
                                 [
                                     -118.93598547,
                                     40.79358571
                                 ],
                                 [
                                     -118.95793211,
                                     40.7819306
                                 ],
                                 [
                                     -118.98220146,
                                     40.77334426
                                 ],
                                 [
                                     -119.00805884,
                                     40.76808637
                                 ],
                                 [
                                     -119.03472222,
                                     40.7663159
                                 ],
                                 [
                                     -119.06138561,
                                     40.76808637
                                 ],
                                 [
                                     -119.08724298,
                                     40.77334426
                                 ],
                                 [
                                     -119.11151234,
                                     40.7819306
                                 ],
                                 [
                                     -119.13345897,
                                     40.79358571
                                 ],
                                 [
                                     -119.15241751,
                                     40.80795693
                                 ],
                                 [
                                     -119.16781191,
                                     40.8246092
                                 ],
                                 [
                                     -119.17917301,
                                     40.84303802
                                 ],
                                 [
                                     -119.18615291,
                                     40.86268467
                                 ],
                                 [
                                     -119.18853588,
                                     40.882953
                                 ],
                                 [
                                     -119.18624535,
                                     40.90322743
                                 ],
                                 [
                                     -119.17934673,
                                     40.92289169
                                 ],
                                 [
                                     -119.16804597,
                                     40.94134748
                                 ],
                                 [
                                     -119.15268367,
                                     40.95803283
                                 ],
                                 [
                                     -119.13372513,
                                     40.97243926
                                 ],
                                 [
                                     -119.1117464,
                                     40.98412745
                                 ],
                                 [
                                     -119.08741671,
                                     40.99274076
                                 ],
                                 [
                                     -119.06147804,
                                     40.99801626
                                 ],
                                 [
                                     -119.03472222,
                                     40.99979284
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "101"
                     },
                     "notam": {
                         "id": "NOTAM_1_73582649",
                         "number": "4/1518",
                         "type": "N",
                         "issued": "2024-09-06T04:09:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-06T04:00:00.000Z",
                         "effectiveEnd": "2024-09-25T22:00:00.000Z",
                         "text": "AIRSPACE ADS-B, AUTO DEPENDENT SURVEILLANCE\nREBROADCAST (ADS-R), TFC INFO SER BCST (TIS-B), FLT INFO SER\nBCST (FIS-B) SER MAY NOT BE AVBL WI AN AREA DEFINED AS 32NM RADIUS \nOF 441749N1190429W. AP AIRSPACE AFFECTED MAY INCLUDE GCD, SEA.\n6000FT-8000FT",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-06T04:10:00.000Z",
                         "icaoLocation": "KZLC"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/1518 ZLC AIRSPACE ADS-B, AUTO DEPENDENT SURVEILLANCE\nREBROADCAST (ADS-R), TFC INFO SER BCST (TIS-B), FLT INFO SER\nBCST (FIS-B) SER MAY NOT BE AVBL WI AN AREA DEFINED AS 32NM RADIUS \nOF 441749N1190429W. AP AIRSPACE AFFECTED MAY INCLUDE GCD, SEA.\n6000FT-8000FT\n2409060400-2409252200EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection"
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "106"
                     },
                     "notam": {
                         "id": "NOTAM_1_73589305",
                         "number": "4/1713",
                         "type": "N",
                         "issued": "2024-09-06T16:48:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-15T04:30:00.000Z",
                         "effectiveEnd": "2024-09-15T09:00:00.000Z",
                         "text": "WY..AIRSPACE JACKSON, WY..LASER LGT DEMONSTRATION WI\nAN AREA DEFINED AS A 1 NM RADIUS OF 433417N1104711W OR (JAC206004),\nSFC-UNL. LASER LGT BEAM MAY BE INJURIOUS TO PILOT/PAX EYES WI 4218FT\nVER OF THE LGT SOURCE. FLASH BLINDNESS OR COCKPIT ILLUMINATION MAY\nOCCUR BEYOND THESE DIST. SALT LAKE CITY ARTCC/ZLC/ TELEPHONE\n801-320-2565 IS THE FAA CDN FAC",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-06T16:50:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "433417N1104711W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/1713 ZLC WY..AIRSPACE JACKSON, WY..LASER LGT DEMONSTRATION WI\nAN AREA DEFINED AS A 1 NM RADIUS OF 433417N1104711W OR (JAC206004),\nSFC-UNL. LASER LGT BEAM MAY BE INJURIOUS TO PILOT/PAX EYES WI 4218FT\nVER OF THE LGT SOURCE. FLASH BLINDNESS OR COCKPIT ILLUMINATION MAY\nOCCUR BEYOND THESE DIST. SALT LAKE CITY ARTCC/ZLC/ TELEPHONE\n801-320-2565 IS THE FAA CDN FAC 2409150430-2409150900"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Point",
                         "coordinates": [
                             -110.79,
                             43.57
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73590931",
                         "number": "4/1823",
                         "type": "N",
                         "issued": "2024-09-06T19:57:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-12T18:30:00.000Z",
                         "effectiveEnd": "2024-09-12T21:30:00.000Z",
                         "text": "UT..AIRSPACE OGDEN, UT..TEMPORARY FLIGHT\nRESTRICTIONS WITHIN AN AREA DEFINED AS 5NM RADIUS OF 413900N1122300W\n(OGD319029) STATIC GROUND BASED ROCKET ENGINE TEST.\nGROUND DEBRIS POSSIBLE SFC-15000FT PURSUANT TO 14 CFR SECTION\n91.137(A)(1) TEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT. ONLY\nRELIEF ACFT OPS UNDER DIRECTION OF SALT LAKE ARTCC ARE\nAUTHORIZED IN THE AIRSPACE. SALT LAKE ARTCC TEL 801-320-2560\nIS IN CHARGE OF ON SCENE EMERGENCY RESPONSE ACTIVITY. SALT LAKE CITY\n/ZLC/ ARTCC TEL 801-320-2560 IS THE FAA CDN FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-06T19:58:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "413900N1122300W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/1823 ZLC UT..AIRSPACE OGDEN, UT..TEMPORARY FLIGHT\nRESTRICTIONS WITHIN AN AREA DEFINED AS 5NM RADIUS OF 413900N1122300W\n(OGD319029) STATIC GROUND BASED ROCKET ENGINE TEST.\nGROUND DEBRIS POSSIBLE SFC-15000FT PURSUANT TO 14 CFR SECTION\n91.137(A)(1) TEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT. ONLY\nRELIEF ACFT OPS UNDER DIRECTION OF SALT LAKE ARTCC ARE\nAUTHORIZED IN THE AIRSPACE. SALT LAKE ARTCC TEL 801-320-2560\nIS IN CHARGE OF ON SCENE EMERGENCY RESPONSE ACTIVITY. SALT LAKE CITY\n/ZLC/ ARTCC TEL 801-320-2560 IS THE FAA CDN FACILITY.\n2409121830-2409122130"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "15000",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -112.49449345,
                                     41.64994625
                                 ],
                                 [
                                     -112.49278017,
                                     41.63547022
                                 ],
                                 [
                                     -112.48774364,
                                     41.62143709
                                 ],
                                 [
                                     -112.47953882,
                                     41.60827283
                                 ],
                                 [
                                     -112.46841645,
                                     41.5963768
                                 ],
                                 [
                                     -112.45471522,
                                     41.58610968
                                 ],
                                 [
                                     -112.43885145,
                                     41.57778258
                                 ],
                                 [
                                     -112.42130637,
                                     41.57164774
                                 ],
                                 [
                                     -112.40261163,
                                     41.56789095
                                 ],
                                 [
                                     -112.38333333,
                                     41.56662591
                                 ],
                                 [
                                     -112.36405504,
                                     41.56789095
                                 ],
                                 [
                                     -112.3453603,
                                     41.57164774
                                 ],
                                 [
                                     -112.32781522,
                                     41.57778258
                                 ],
                                 [
                                     -112.31195144,
                                     41.58610968
                                 ],
                                 [
                                     -112.29825022,
                                     41.5963768
                                 ],
                                 [
                                     -112.28712784,
                                     41.60827283
                                 ],
                                 [
                                     -112.27892302,
                                     41.62143709
                                 ],
                                 [
                                     -112.27388649,
                                     41.63547022
                                 ],
                                 [
                                     -112.27217322,
                                     41.64994625
                                 ],
                                 [
                                     -112.27383747,
                                     41.66442549
                                 ],
                                 [
                                     -112.2788309,
                                     41.67846785
                                 ],
                                 [
                                     -112.28700372,
                                     41.69164624
                                 ],
                                 [
                                     -112.29810907,
                                     41.70355961
                                 ],
                                 [
                                     -112.31181029,
                                     41.7138452
                                 ],
                                 [
                                     -112.32769109,
                                     41.72218964
                                 ],
                                 [
                                     -112.34526817,
                                     41.72833861
                                 ],
                                 [
                                     -112.36400602,
                                     41.73210464
                                 ],
                                 [
                                     -112.38333333,
                                     41.73337287
                                 ],
                                 [
                                     -112.40266065,
                                     41.73210464
                                 ],
                                 [
                                     -112.42139849,
                                     41.72833861
                                 ],
                                 [
                                     -112.43897557,
                                     41.72218964
                                 ],
                                 [
                                     -112.45485637,
                                     41.7138452
                                 ],
                                 [
                                     -112.4685576,
                                     41.70355961
                                 ],
                                 [
                                     -112.47966295,
                                     41.69164624
                                 ],
                                 [
                                     -112.48783577,
                                     41.67846785
                                 ],
                                 [
                                     -112.49282919,
                                     41.66442549
                                 ],
                                 [
                                     -112.49449345,
                                     41.64994625
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73598288",
                         "number": "4/2086",
                         "type": "N",
                         "issued": "2024-09-08T01:53:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-08T02:00:00.000Z",
                         "effectiveEnd": "2024-09-22T02:00:00.000Z",
                         "text": "ID..AIRSPACE 45NM NE OF BOISE, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS\n442228N1152401W (DNJ105041.8) TO\n442618N1151040W (DNJ095048.3) TO\n442242N1145403W (DNJ094060.7) TO\n440102N1150004W (DNJ112068.6) TO\n440400N1152831W (DNJ124052.5) TO POINT OF ORIGIN SFC-13500FT.\nTO PROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING. PURSUANT TO \n14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE\nIN EFFECT. BOISE NATIONAL FOREST TEL 208-384-3398 OR FREQ\n120.125/THE WAPITI FIRE IS IN CHARGE OF THE OPS.\nSALT LAKE CITY/ZLC/ARTCC TEL 801-320-2560 IS THE FAA CDN FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-08T01:53:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "442228N1152401W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/2086 ZLC ID..AIRSPACE 45NM NE OF BOISE, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS\n442228N1152401W (DNJ105041.8) TO\n442618N1151040W (DNJ095048.3) TO\n442242N1145403W (DNJ094060.7) TO\n440102N1150004W (DNJ112068.6) TO\n440400N1152831W (DNJ124052.5) TO POINT OF ORIGIN SFC-13500FT.\nTO PROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING. PURSUANT TO \n14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE\nIN EFFECT. BOISE NATIONAL FOREST TEL 208-384-3398 OR FREQ\n120.125/THE WAPITI FIRE IS IN CHARGE OF THE OPS.\nSALT LAKE CITY/ZLC/ARTCC TEL 801-320-2560 IS THE FAA CDN FACILITY.\n2409080200-2409220200EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "13500",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -115.40027778,
                                     44.37444444
                                 ],
                                 [
                                     -115.17777778,
                                     44.43833333
                                 ],
                                 [
                                     -114.90083333,
                                     44.37833333
                                 ],
                                 [
                                     -115.00111111,
                                     44.01722222
                                 ],
                                 [
                                     -115.47527778,
                                     44.06666667
                                 ],
                                 [
                                     -115.40027778,
                                     44.37444444
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73600508",
                         "number": "4/2159",
                         "type": "N",
                         "issued": "2024-09-08T12:49:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-08T14:00:00.000Z",
                         "effectiveEnd": "2024-09-22T03:00:00.000Z",
                         "text": "MT..AIRSPACE 2NM W OF STEVENSVILLE, MT..TEMPORARY\nFLIGHT RESTRICTIONS WI AN AREA DEFINED AS 463700N/1141800W\n(MSO194019.6) TO 463700N1140700W (MSO171017.5) TO\n462500N1140730W (MSO170029.5) TO 462500N1141900W (MSO185031.0) TO\nPOINT OF ORIGIN SFC-11500FT TO PROVIDE A SAFE ENVIRONMENT FOR\nFIREFIGHTING AIRCRAFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2)\nTEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT. BITTERROOT DISPATCH\nTELEPHONE 406-363-7133 OR FREQ 118.2250/THE SHARROTT CREEK FIRE IS\nIN CHARGE OF THE OPERATION. SALT LAKE CITY /ZLC/ ARTCC TELEPHONE\n801-320-2560 IS THE FAA COORDINATION FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-08T12:49:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "463700N1140700W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/2159 ZLC MT..AIRSPACE 2NM W OF STEVENSVILLE, MT..TEMPORARY\nFLIGHT RESTRICTIONS WI AN AREA DEFINED AS 463700N/1141800W\n(MSO194019.6) TO 463700N1140700W (MSO171017.5) TO\n462500N1140730W (MSO170029.5) TO 462500N1141900W (MSO185031.0) TO\nPOINT OF ORIGIN SFC-11500FT TO PROVIDE A SAFE ENVIRONMENT FOR\nFIREFIGHTING AIRCRAFT OPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2)\nTEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT. BITTERROOT DISPATCH\nTELEPHONE 406-363-7133 OR FREQ 118.2250/THE SHARROTT CREEK FIRE IS\nIN CHARGE OF THE OPERATION. SALT LAKE CITY /ZLC/ ARTCC TELEPHONE\n801-320-2560 IS THE FAA COORDINATION FACILITY.\n2409081400-2409220300EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "11500",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -114.3,
                                     46.61666667
                                 ],
                                 [
                                     -114.11666667,
                                     46.61666667
                                 ],
                                 [
                                     -114.125,
                                     46.41666667
                                 ],
                                 [
                                     -114.31666667,
                                     46.41666667
                                 ],
                                 [
                                     -114.3,
                                     46.61666667
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73603559",
                         "number": "4/2413",
                         "type": "N",
                         "issued": "2024-09-09T02:35:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-09T14:00:00.000Z",
                         "effectiveEnd": "2024-09-23T03:00:00.000Z",
                         "text": "MT..AIRSPACE 11NM W OF BUTTE, MT..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS 7 NM RADIUS OF 455530N/1125530W\n(COPPERTOWN VOR/DME CPN213009.8) SFC-13500FT .  TO PROVIDE A SAFE\nENVIRONMENT FOR FIREFIGHTING AIRCRAFT OPS. PURSUANT TO 14 CFR\nSECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT.\nDILLON DISPATCH TELEPHONE 406-683-3975 OR FREQ 119.8750/THE LONG TOM\nFIRE IS IN CHARGE OF THE OPERATION. ZLC SALT LAKE CITY /ZLC/ ARTCC\nTELEPHONE 801-320-2560 IS THE FAA COORDINATION FACILITY. DLY\n1400-0300 UTC.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-09T02:35:00.000Z",
                         "icaoLocation": "KZLC"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/2413 ZLC MT..AIRSPACE 11NM W OF BUTTE, MT..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS 7 NM RADIUS OF 455530N/1125530W\n(COPPERTOWN VOR/DME CPN213009.8) SFC-13500FT .  TO PROVIDE A SAFE\nENVIRONMENT FOR FIREFIGHTING AIRCRAFT OPS. PURSUANT TO 14 CFR\nSECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT.\nDILLON DISPATCH TELEPHONE 406-683-3975 OR FREQ 119.8750/THE LONG TOM\nFIRE IS IN CHARGE OF THE OPERATION. ZLC SALT LAKE CITY /ZLC/ ARTCC\nTELEPHONE 801-320-2560 IS THE FAA COORDINATION FACILITY. DLY\n1400-0300 UTC.\n2409091400-2409230300EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "13500",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -112.925,
                                     46.04163414
                                 ],
                                 [
                                     -112.89591795,
                                     46.03985852
                                 ],
                                 [
                                     -112.86772498,
                                     46.03458597
                                 ],
                                 [
                                     -112.8412825,
                                     46.02597764
                                 ],
                                 [
                                     -112.8173975,
                                     46.01429654
                                 ],
                                 [
                                     -112.79679756,
                                     45.99989941
                                 ],
                                 [
                                     -112.78010859,
                                     45.98322558
                                 ],
                                 [
                                     -112.76783576,
                                     45.96478348
                                 ],
                                 [
                                     -112.7603484,
                                     45.94513489
                                 ],
                                 [
                                     -112.75786924,
                                     45.92487779
                                 ],
                                 [
                                     -112.76046819,
                                     45.90462798
                                 ],
                                 [
                                     -112.76806089,
                                     45.88500041
                                 ],
                                 [
                                     -112.78041192,
                                     45.8665905
                                 ],
                                 [
                                     -112.79714249,
                                     45.84995617
                                 ],
                                 [
                                     -112.81774243,
                                     45.83560106
                                 ],
                                 [
                                     -112.84158583,
                                     45.82395946
                                 ],
                                 [
                                     -112.86795012,
                                     45.81538333
                                 ],
                                 [
                                     -112.89603774,
                                     45.81013179
                                 ],
                                 [
                                     -112.925,
                                     45.80836347
                                 ],
                                 [
                                     -112.95396226,
                                     45.81013179
                                 ],
                                 [
                                     -112.98204988,
                                     45.81538333
                                 ],
                                 [
                                     -113.00841417,
                                     45.82395946
                                 ],
                                 [
                                     -113.03225757,
                                     45.83560106
                                 ],
                                 [
                                     -113.05285751,
                                     45.84995617
                                 ],
                                 [
                                     -113.06958808,
                                     45.8665905
                                 ],
                                 [
                                     -113.08193911,
                                     45.88500041
                                 ],
                                 [
                                     -113.08953181,
                                     45.90462798
                                 ],
                                 [
                                     -113.09213076,
                                     45.92487779
                                 ],
                                 [
                                     -113.0896516,
                                     45.94513489
                                 ],
                                 [
                                     -113.08216424,
                                     45.96478348
                                 ],
                                 [
                                     -113.06989141,
                                     45.98322558
                                 ],
                                 [
                                     -113.05320244,
                                     45.99989941
                                 ],
                                 [
                                     -113.0326025,
                                     46.01429654
                                 ],
                                 [
                                     -113.0087175,
                                     46.02597764
                                 ],
                                 [
                                     -112.98227502,
                                     46.03458597
                                 ],
                                 [
                                     -112.95408205,
                                     46.03985852
                                 ],
                                 [
                                     -112.925,
                                     46.04163414
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73604790",
                         "number": "4/2435",
                         "type": "N",
                         "issued": "2024-09-09T07:04:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-09T15:00:00.000Z",
                         "effectiveEnd": "2024-09-23T03:00:00.000Z",
                         "text": "ID..AIRSPACE 6NM W OF CASCADE, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS \n443941N1162600W (DNJ218011.6) TO\n443941N1161115W (DNJ154006.4) TO\n441509N1161115W (DNJ160030.9) TO\n441509N1162600W (DNJ179032.4) TO POINT OF ORIGIN SFC-12000FT TO\nPROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING ACFT OPS. PURSUANT TO\n14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN\nEFFECT. BOISE NATIONAL FOREST TELEPHONE 208-384-3398 OR FREQ\n124.0500/LAVA FIRE IS IN CHARGE OF THE OPERATION. SALT LAKE CITY\n/ZLC/ ARTCC TELEPHONE 801-320-2560 IS THE FAA COORDINATION FACILITY.\nDLY 1500-0300",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-09T07:04:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "443941N1162600W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/2435 ZLC ID..AIRSPACE 6NM W OF CASCADE, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS \n443941N1162600W (DNJ218011.6) TO\n443941N1161115W (DNJ154006.4) TO\n441509N1161115W (DNJ160030.9) TO\n441509N1162600W (DNJ179032.4) TO POINT OF ORIGIN SFC-12000FT TO\nPROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING ACFT OPS. PURSUANT TO\n14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN\nEFFECT. BOISE NATIONAL FOREST TELEPHONE 208-384-3398 OR FREQ\n124.0500/LAVA FIRE IS IN CHARGE OF THE OPERATION. SALT LAKE CITY\n/ZLC/ ARTCC TELEPHONE 801-320-2560 IS THE FAA COORDINATION FACILITY.\nDLY 1500-0300\n2409091500-2409230300EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "12000",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -116.43333333,
                                     44.66138889
                                 ],
                                 [
                                     -116.1875,
                                     44.66138889
                                 ],
                                 [
                                     -116.1875,
                                     44.2525
                                 ],
                                 [
                                     -116.43333333,
                                     44.2525
                                 ],
                                 [
                                     -116.43333333,
                                     44.66138889
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73607892",
                         "number": "4/2503",
                         "type": "N",
                         "issued": "2024-09-09T13:22:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-15T14:00:00.000Z",
                         "effectiveEnd": "2024-09-16T06:00:00.000Z",
                         "text": "NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-09T13:22:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "405259N1190205W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/2503 ZLC NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.\n2409151400-2409160600"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "910",
                             "uomUpperLevel": "FL",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -119.03472222,
                                     40.99979284
                                 ],
                                 [
                                     -119.0079664,
                                     40.99801626
                                 ],
                                 [
                                     -118.98202774,
                                     40.99274076
                                 ],
                                 [
                                     -118.95769805,
                                     40.98412745
                                 ],
                                 [
                                     -118.93571931,
                                     40.97243926
                                 ],
                                 [
                                     -118.91676078,
                                     40.95803283
                                 ],
                                 [
                                     -118.90139848,
                                     40.94134748
                                 ],
                                 [
                                     -118.89009771,
                                     40.92289169
                                 ],
                                 [
                                     -118.8831991,
                                     40.90322743
                                 ],
                                 [
                                     -118.88090857,
                                     40.882953
                                 ],
                                 [
                                     -118.88329153,
                                     40.86268467
                                 ],
                                 [
                                     -118.89027143,
                                     40.84303802
                                 ],
                                 [
                                     -118.90163253,
                                     40.8246092
                                 ],
                                 [
                                     -118.91702694,
                                     40.80795693
                                 ],
                                 [
                                     -118.93598547,
                                     40.79358571
                                 ],
                                 [
                                     -118.95793211,
                                     40.7819306
                                 ],
                                 [
                                     -118.98220146,
                                     40.77334426
                                 ],
                                 [
                                     -119.00805884,
                                     40.76808637
                                 ],
                                 [
                                     -119.03472222,
                                     40.7663159
                                 ],
                                 [
                                     -119.06138561,
                                     40.76808637
                                 ],
                                 [
                                     -119.08724298,
                                     40.77334426
                                 ],
                                 [
                                     -119.11151234,
                                     40.7819306
                                 ],
                                 [
                                     -119.13345897,
                                     40.79358571
                                 ],
                                 [
                                     -119.15241751,
                                     40.80795693
                                 ],
                                 [
                                     -119.16781191,
                                     40.8246092
                                 ],
                                 [
                                     -119.17917301,
                                     40.84303802
                                 ],
                                 [
                                     -119.18615291,
                                     40.86268467
                                 ],
                                 [
                                     -119.18853588,
                                     40.882953
                                 ],
                                 [
                                     -119.18624535,
                                     40.90322743
                                 ],
                                 [
                                     -119.17934673,
                                     40.92289169
                                 ],
                                 [
                                     -119.16804597,
                                     40.94134748
                                 ],
                                 [
                                     -119.15268367,
                                     40.95803283
                                 ],
                                 [
                                     -119.13372513,
                                     40.97243926
                                 ],
                                 [
                                     -119.1117464,
                                     40.98412745
                                 ],
                                 [
                                     -119.08741671,
                                     40.99274076
                                 ],
                                 [
                                     -119.06147804,
                                     40.99801626
                                 ],
                                 [
                                     -119.03472222,
                                     40.99979284
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73607893",
                         "number": "4/2504",
                         "type": "N",
                         "issued": "2024-09-09T13:22:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-14T14:00:00.000Z",
                         "effectiveEnd": "2024-09-15T06:00:00.000Z",
                         "text": "NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-09T13:22:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "405259N1190205W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/2504 ZLC NV..AIRSPACE BLACK ROCK, NV..TEMPORARY FLIGHT \nRESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF 405259N1190205W \n(LLC319050) SFC-UNL TO PROVIDE A SAFE ENVIRONMENT FOR ROCKET \nLAUNCH ACT. PURSUANT TO 14 CFR SECTION 91.143. AEROPAC ROCKET CLUB,\n415-827-6469 IS IN CHARGE OF THE OPS. SALT LAKE /ZLC/ ARTCC TEL\n801-320-2560 IS THE FAA CDN FACILITY.\n2409141400-2409150600"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "910",
                             "uomUpperLevel": "FL",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -119.18853588,
                                     40.882953
                                 ],
                                 [
                                     -119.18615291,
                                     40.86268467
                                 ],
                                 [
                                     -119.17917301,
                                     40.84303802
                                 ],
                                 [
                                     -119.16781191,
                                     40.8246092
                                 ],
                                 [
                                     -119.15241751,
                                     40.80795693
                                 ],
                                 [
                                     -119.13345897,
                                     40.79358571
                                 ],
                                 [
                                     -119.11151234,
                                     40.7819306
                                 ],
                                 [
                                     -119.08724298,
                                     40.77334426
                                 ],
                                 [
                                     -119.06138561,
                                     40.76808637
                                 ],
                                 [
                                     -119.03472222,
                                     40.7663159
                                 ],
                                 [
                                     -119.00805884,
                                     40.76808637
                                 ],
                                 [
                                     -118.98220146,
                                     40.77334426
                                 ],
                                 [
                                     -118.95793211,
                                     40.7819306
                                 ],
                                 [
                                     -118.93598547,
                                     40.79358571
                                 ],
                                 [
                                     -118.91702694,
                                     40.80795693
                                 ],
                                 [
                                     -118.90163253,
                                     40.8246092
                                 ],
                                 [
                                     -118.89027143,
                                     40.84303802
                                 ],
                                 [
                                     -118.88329153,
                                     40.86268467
                                 ],
                                 [
                                     -118.88090857,
                                     40.882953
                                 ],
                                 [
                                     -118.8831991,
                                     40.90322743
                                 ],
                                 [
                                     -118.89009771,
                                     40.92289169
                                 ],
                                 [
                                     -118.90139848,
                                     40.94134748
                                 ],
                                 [
                                     -118.91676078,
                                     40.95803283
                                 ],
                                 [
                                     -118.93571931,
                                     40.97243926
                                 ],
                                 [
                                     -118.95769805,
                                     40.98412745
                                 ],
                                 [
                                     -118.98202774,
                                     40.99274076
                                 ],
                                 [
                                     -119.0079664,
                                     40.99801626
                                 ],
                                 [
                                     -119.03472222,
                                     40.99979284
                                 ],
                                 [
                                     -119.06147804,
                                     40.99801626
                                 ],
                                 [
                                     -119.08741671,
                                     40.99274076
                                 ],
                                 [
                                     -119.1117464,
                                     40.98412745
                                 ],
                                 [
                                     -119.13372513,
                                     40.97243926
                                 ],
                                 [
                                     -119.15268367,
                                     40.95803283
                                 ],
                                 [
                                     -119.16804597,
                                     40.94134748
                                 ],
                                 [
                                     -119.17934673,
                                     40.92289169
                                 ],
                                 [
                                     -119.18624535,
                                     40.90322743
                                 ],
                                 [
                                     -119.18853588,
                                     40.882953
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73609121",
                         "number": "4/2576",
                         "type": "N",
                         "issued": "2024-09-09T14:56:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-09T15:00:00.000Z",
                         "effectiveEnd": "2024-09-24T03:00:00.000Z",
                         "text": "ID..AIRSPACE 25NM SW OF CHALLIS, ID..TEMPORARY\nFLIGHT RESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF\n440458N1143132W (LKT186059.4) SFC-15000FT TO\nPROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING. PURSUANT TO 14 CFR\nSECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT.\nSOUTH IDAHO DISPATCH TELEPHONE 208-732-7265 OR FREQ 123.4000/FROG\nFIRE IS IN CHARGE OF THE OPERATION. SALT LAKE CITY /ZLC/ ARTCC\nTELEPHONE 801-320-2560 IS THE FAA COORDINATION FACILITY. DLY\n1500-0300",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-09T14:57:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "440458N1143132W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/2576 ZLC ID..AIRSPACE 25NM SW OF CHALLIS, ID..TEMPORARY\nFLIGHT RESTRICTIONS WI AN AREA DEFINED AS 7NM RADIUS OF\n440458N1143132W (LKT186059.4) SFC-15000FT TO\nPROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING. PURSUANT TO 14 CFR\nSECTION 91.137(A)(2) TEMPORARY FLIGHT RESTRICTIONS ARE IN EFFECT.\nSOUTH IDAHO DISPATCH TELEPHONE 208-732-7265 OR FREQ 123.4000/FROG\nFIRE IS IN CHARGE OF THE OPERATION. SALT LAKE CITY /ZLC/ ARTCC\nTELEPHONE 801-320-2560 IS THE FAA COORDINATION FACILITY. DLY\n1500-0300 2409091500-2409240300EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "15000",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -114.52555556,
                                     44.1994497
                                 ],
                                 [
                                     -114.49739456,
                                     44.19767374
                                 ],
                                 [
                                     -114.47009417,
                                     44.19240014
                                 ],
                                 [
                                     -114.44448822,
                                     44.18379003
                                 ],
                                 [
                                     -114.42135795,
                                     44.1721064
                                 ],
                                 [
                                     -114.40140786,
                                     44.15770592
                                 ],
                                 [
                                     -114.3852441,
                                     44.14102794
                                 ],
                                 [
                                     -114.37335606,
                                     44.12258086
                                 ],
                                 [
                                     -114.36610172,
                                     44.10292657
                                 ],
                                 [
                                     -114.36369715,
                                     44.08266313
                                 ],
                                 [
                                     -114.36621051,
                                     44.06240653
                                 ],
                                 [
                                     -114.37356053,
                                     44.04277194
                                 ],
                                 [
                                     -114.38551958,
                                     44.02435505
                                 ],
                                 [
                                     -114.40172113,
                                     44.00771409
                                 ],
                                 [
                                     -114.42167122,
                                     43.99335301
                                 ],
                                 [
                                     -114.4447637,
                                     43.9817064
                                 ],
                                 [
                                     -114.47029864,
                                     43.97312648
                                 ],
                                 [
                                     -114.49750336,
                                     43.96787258
                                 ],
                                 [
                                     -114.52555556,
                                     43.96610347
                                 ],
                                 [
                                     -114.55360775,
                                     43.96787258
                                 ],
                                 [
                                     -114.58081247,
                                     43.97312648
                                 ],
                                 [
                                     -114.60634741,
                                     43.9817064
                                 ],
                                 [
                                     -114.62943989,
                                     43.99335301
                                 ],
                                 [
                                     -114.64938998,
                                     44.00771409
                                 ],
                                 [
                                     -114.66559153,
                                     44.02435505
                                 ],
                                 [
                                     -114.67755058,
                                     44.04277194
                                 ],
                                 [
                                     -114.6849006,
                                     44.06240653
                                 ],
                                 [
                                     -114.68741396,
                                     44.08266313
                                 ],
                                 [
                                     -114.68500939,
                                     44.10292657
                                 ],
                                 [
                                     -114.67775505,
                                     44.12258086
                                 ],
                                 [
                                     -114.66586701,
                                     44.14102794
                                 ],
                                 [
                                     -114.64970325,
                                     44.15770592
                                 ],
                                 [
                                     -114.62975316,
                                     44.1721064
                                 ],
                                 [
                                     -114.6066229,
                                     44.18379003
                                 ],
                                 [
                                     -114.58101695,
                                     44.19240014
                                 ],
                                 [
                                     -114.55371655,
                                     44.19767374
                                 ],
                                 [
                                     -114.52555556,
                                     44.1994497
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73610963",
                         "number": "4/2692",
                         "type": "N",
                         "issued": "2024-09-09T18:05:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-09T18:00:00.000Z",
                         "effectiveEnd": "2024-09-24T03:00:00.000Z",
                         "text": "ID..AIRSPACE 1NM W CASCADE, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS\n443415N1161015W (DNJ154011.9) TO\n443415N1160530W (DNJ138012.8) TO\n443145N1160415W (DNJ139015.4) TO\n442845N1160300W (DNJ140018.5) TO\n442100N1160300W (DNJ146025.9) TO\n442100N1161015W (DNJ158025.1) TO POINT OF ORIGIN SFC-11500FT.\nTO PROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING ACFT OPS. \nPURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT \nRESTRICTIONS ARE IN EFFECT. BOISE NATIONAL FOREST TEL 208-384-3398\nOR FREQ 127.2000/BOULDER FIRE IS IN CHARGE OF THE OPS.\nSALT LAKE CITY/ZLC/ARTCC TEL 801-320-2560 IS THE FAA CDN FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-09T18:06:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "443415N1161015W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/2692 ZLC ID..AIRSPACE 1NM W CASCADE, ID..TEMPORARY FLIGHT\nRESTRICTIONS WI AN AREA DEFINED AS\n443415N1161015W (DNJ154011.9) TO\n443415N1160530W (DNJ138012.8) TO\n443145N1160415W (DNJ139015.4) TO\n442845N1160300W (DNJ140018.5) TO\n442100N1160300W (DNJ146025.9) TO\n442100N1161015W (DNJ158025.1) TO POINT OF ORIGIN SFC-11500FT.\nTO PROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING ACFT OPS. \nPURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT \nRESTRICTIONS ARE IN EFFECT. BOISE NATIONAL FOREST TEL 208-384-3398\nOR FREQ 127.2000/BOULDER FIRE IS IN CHARGE OF THE OPS.\nSALT LAKE CITY/ZLC/ARTCC TEL 801-320-2560 IS THE FAA CDN FACILITY.\n2409091800-2409240300EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Polygon",
                         "heightInformation": {
                             "upperLevel": "11500",
                             "uomUpperLevel": "FT",
                             "lowerLevel": "0",
                             "uomLowerLevel": "FT"
                         },
                         "coordinates": [
                             [
                                 [
                                     -116.17083333,
                                     44.57083333
                                 ],
                                 [
                                     -116.09166667,
                                     44.57083333
                                 ],
                                 [
                                     -116.07083333,
                                     44.52916667
                                 ],
                                 [
                                     -116.05,
                                     44.47916667
                                 ],
                                 [
                                     -116.05,
                                     44.35
                                 ],
                                 [
                                     -116.17083333,
                                     44.35
                                 ],
                                 [
                                     -116.17083333,
                                     44.57083333
                                 ]
                             ]
                         ]
                     }
                 ]
             }
         },
         {
             "type": "Feature",
             "properties": {
                 "coreNOTAMData": {
                     "notamEvent": {
                         "scenario": "100005"
                     },
                     "notam": {
                         "id": "NOTAM_1_73614493",
                         "number": "4/2921",
                         "type": "N",
                         "issued": "2024-09-10T03:03:00.000Z",
                         "selectionCode": "QXXXX",
                         "location": "ZLC",
                         "effectiveStart": "2024-09-10T03:15:00.000Z",
                         "effectiveEnd": "2024-09-25T03:00:00.000Z",
                         "text": "MT..AIRSPACE 10NM EAST OF HAMILTON, MT..TEMPORARY\nFLIGHT RESTRICTIONS WI AN AREA DEFINED AS\n462625N1134235W (MSO138032.0) TO\n462025N1133110W (MSO133041.3) TO\n460605N1134610W (MSO152050.1) TO\n461425N1135735W (MSO160040.4) TO POINT OF ORIGIN\nSFC-10500FT.  TO PROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING ACFT\nOPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT\nRESTRICTIONS ARE IN EFFECT. BITTERROOT DISPATCH TELEPHONE\n406-363-7133 OR FREQ 120.725/THE DALY FIRE IS IN CHARGE OF THE\nOPERATION. ZLC SALT LAKE CITY /ZLC/ ARTCC TELEPHONE 801-320-2560 IS\nTHE FAA COORDINATION FACILITY.",
                         "classification": "FDC",
                         "accountId": "FDC",
                         "lastUpdated": "2024-09-10T03:03:00.000Z",
                         "icaoLocation": "KZLC",
                         "coordinates": "462625N1134235W"
                     },
                     "notamTranslation": [
                         {
                             "type": "LOCAL_FORMAT",
                             "simpleText": "!FDC 4/2921 ZLC MT..AIRSPACE 10NM EAST OF HAMILTON, MT..TEMPORARY\nFLIGHT RESTRICTIONS WI AN AREA DEFINED AS\n462625N1134235W (MSO138032.0) TO\n462025N1133110W (MSO133041.3) TO\n460605N1134610W (MSO152050.1) TO\n461425N1135735W (MSO160040.4) TO POINT OF ORIGIN\nSFC-10500FT.  TO PROVIDE A SAFE ENVIRONMENT FOR FIRE FIGHTING ACFT\nOPS. PURSUANT TO 14 CFR SECTION 91.137(A)(2) TEMPORARY FLIGHT\nRESTRICTIONS ARE IN EFFECT. BITTERROOT DISPATCH TELEPHONE\n406-363-7133 OR FREQ 120.725/THE DALY FIRE IS IN CHARGE OF THE\nOPERATION. ZLC SALT LAKE CITY /ZLC/ ARTCC TELEPHONE 801-320-2560 IS\nTHE FAA COORDINATION FACILITY. \n2409100315-2409250300EST"
                         }
                     ]
                 }
             },
             "geometry": {
                 "type": "GeometryCollection",
                 "geometries": [
                     {
                         "type": "Point",
                         "coordinates": [
                             -113.71,
                             46.44
                         ]
                     }
                 ]
             }
         }
     ]
 }
 */

