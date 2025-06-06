//
//  HotspotManager.swift
//  PiCam
//
//  Created by Tyson Miles on 30/3/2025.
//
import UIKit
import NetworkExtension

class HotspotManager {
    func connectToHotspot(ssid: String, password: String, completion: @escaping (Bool) -> Void) {
        let configuration = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
        configuration.joinOnce = false // Set to true if you want to join the network once
        
        NEHotspotConfigurationManager.shared.apply(configuration) { error in
            if let error = error {
                print("Connection error: \(error)")
                print( "PiCam Connect requires Network Extension entitlement. If you see this error, please contact support, or add an Issue to our GitHub repository. ER: CL-928")
                completion(false)
                
            } else {
                print("Connected successfully")
                completion(true)
            }
        }
    }
}
