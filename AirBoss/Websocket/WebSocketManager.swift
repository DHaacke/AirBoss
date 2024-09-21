//
//  WebsocketManager.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/18/24.
//

import Foundation
import Starscream
import CoreLocation

@Observable
class WebSocketManager: NSObject, WebSocketDelegate {
  
    let locationManager = LocationManager()
    
    var message: String   = ""
    var isConnected: Bool = false
    var isDisconnected: Bool = false
    var isFailure: Bool   = false
    
    var socket: WebSocket!
    
    var traffic: TrafficModel?
    var homeLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        // connect()
        let dispatchQueue = DispatchQueue(label: "ConnectIdentification", qos: .background)
        dispatchQueue.asyncAfter(deadline: .now() + 4.0) {
            self.connect()
        }
    }

    func connect() {
        guard let url = URL(string: "ws://192.168.1.208/traffic") else {
           isFailure = true
           return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }

    func disconnect() {
        socket.disconnect()
    }

    func sendMessage(_ message: String) {
        socket.write(string: message)
    }

    func websocketDidConnect(socket: WebSocketClient) {
        print("Connected to WebSocket")
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        isDisconnected = true
        print("Disconnected from WebSocket: \(error?.localizedDescription ?? "No error")")
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//            print("Received text: \(text)")
//            DispatchQueue.main.async {
//                self.message = text
//            }
        }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count) bytes")
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
           case .connected:   // (let headers)
               isConnected = true
           case .disconnected(let reason, let code):
               isConnected = false
               print("websocket is disconnected: \(reason) with code: \(code)")
           case .text(let str):
                // print("Received ADSB text: \(str)")
                traffic = processIncomingTraffic(with: str.toData())
                if let traffic {
                    DispatchQueue.main.async {
                        self.traffic = traffic
                    }
                }
                
           case .binary(let data):
               print("Received data: \(data.count)")
           case .ping(_):
               break
           case .pong(_):
               break
           case .viabilityChanged(_):
               break
           case .reconnectSuggested(_):
               break
           case .cancelled:
               isConnected = false
           case .error(let error):
               isConnected = false
               handleError(error)
           case .peerClosed:
               break
           }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
    
    func processIncomingTraffic(with rawTraffic: Data) -> TrafficModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ADSB.self, from: rawTraffic)
            
            //  print(decodedData)
            
            let icaoAddress: Int64    = decodedData.Icao_addr
            let callSign              = decodedData.Tail
            let regNo                 = decodedData.Reg
            let priority              = decodedData.PriorityStatus
            let onGround              = decodedData.OnGround
            let squawk                = decodedData.Squawk
            var lat                   = decodedData.Lat
            var lon                   = decodedData.Lng
            let altitude              = decodedData.Alt
            let course                = decodedData.Track
            let speed                 = decodedData.Speed
            let distance              = decodedData.Distance
            let bearing               = decodedData.Bearing
            let vvel                  = decodedData.Vvel
            let turnRate              = decodedData.TurnRate
            let latFix                = decodedData.Lat_fix
            let lonFix                = decodedData.Lng_fix
 
            //   V A L I D A T E   P O S I T I O N
            if lat == 0 && lon == 0 && latFix != 0 && lonFix != 0 {
                lat = latFix
                lon = lonFix
            }
            
            // if icaoAddress > 0 && lat != 0 && lon != 0 && onGround == false && altitude < settings.ignoreAircraftAboveFeet && distanceMiles < settings.ignoreAircraftOutsideMiles {
            if lat != 0 && lon != 0 {
                return TrafficModel(icaoAddress: icaoAddress,
                                    callSign: callSign,
                                    regNo: regNo,
                                    priority: priority,
                                    onGround: onGround,
                                    squawk: squawk,
                                    lat: lat,
                                    lon: lon,
                                    altitude: Int(altitude),
                                    course: Int(course),
                                    speed: Int(speed),
                                    distance: Int(distance),
                                    bearing: Int(bearing),
                                    vvel: Int(vvel),
                                    turnRate: Int(turnRate),
                                    icao_type: "",
                                    manufacturer: "",
                                    model: "",
                                    icon: "",
                                    altIcon: "",
                                    alert: "N",
                                    owner: "",
                                    timeStamp: Date().currentTimeStamp(),
                                    homeLocation: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                    homeElevation: 0
                       )
            } else {
                // print("* * * Invalid aircraft:  icao: \(icaoAddress), lat: \(lat), lon: \(lon)")
                // print(decodedData);
                return nil
            }
            
        } catch let DecodingError.dataCorrupted(context) {
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
            print("JSON error: ", error)
        }
        
        return nil
    }

    
}


