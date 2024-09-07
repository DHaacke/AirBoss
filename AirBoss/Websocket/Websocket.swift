//
//  Websocket.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/1/24.
//

import Foundation
import SwiftUI
import Observation
import Combine

@Observable class Websocket {

    var adsb : ADSB?
    var message = String()
    var message_count : Int = 0

    var isFailure: Bool = false;
    
    private var webSocketTask: URLSessionWebSocketTask?

    init() {
        self.connect()
    }

    private func connect() {
        // guard let url = URL(string: "ws://192.168.10.1/traffic") else {
        guard let url = URL(string: "ws://192.168.1.208/traffic") else {
            isFailure = true
            return
        }
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        receiveMessage()
        print("WebSocket connected")
  
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { result in
            switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let message):
                    switch message {
                        case .string(let text):
                            self.message = text
                            self.message_count += 1
                            if let jsonData = text.data(using: .utf8) {
                                do {
                                    self.adsb = try JSONDecoder().decode(ADSB.self, from: jsonData)
                                    if self.adsb != nil {
                                        if let distance = self.adsb?.Distance {
                                            if distance == 0 {
                                                if let distance_estimated = self.adsb?.DistanceEstimated {
                                                    self.adsb?.Distance = distance_estimated
                                                }
                                            }
                                        }
                                        self.adsb?.Distance = self.adsb!.Distance * 0.00062
                                    }
                                    // print(self.adsb ?? "ADSB model not set")
                                } catch {
                                    print("Decoding failed: \(error)")
                                }
                            }
                        case .data(let data):
                            // Handle binary data
                                print(data)
                            break
                        @unknown default:
                            break
                    }
            }
            self.receiveMessage()
        }
    }
    
    func sendMessage(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }
        print("Sending: \(data)")
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
