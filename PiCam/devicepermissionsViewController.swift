//
//  devicepermissionsViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 12/3/2025.
//

import Foundation
import CoreBluetooth
import CoreLocation
import UserNotifications
import NearbyInteraction
import UIKit

class devicepermissionsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPermissions()
            
    }
    
    func requestPermissions() {
        
        CLLocationManager().requestWhenInUseAuthorization()
        BluetoothManager().centralManager.scanForPeripherals(withServices: nil)
        BluetoothManager().centralManager.stopScan()
        print("Reqesting Permissions")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
}
