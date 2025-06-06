//
//  DeviceDetailViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 14/3/2025.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

class DeviceDetailViewController: UIViewController {
    
    // MARK: - Properties
    var device: Device!  // This should be set by the previous view controller
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    @IBOutlet weak var DeviceNameLabel: UILabel!

    override func viewDidLoad() {
        DeviceNameLabel.text = device.devicename
    }
    @IBAction func BackTapped(_ sender: Any) {
        
    }

    // MARK: - Segue Handling
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDeviceHealth" {
            guard let healthVC = segue.destination as? DeviceHealthViewController else {
                fatalError("Unexpected destination view controller")
            }
            
            // Pass the existing device to the health view controller
            healthVC.device = self.device
        }
        if segue.identifier == "showDeviceSettings" {
            guard let setVC = segue.destination as? DeviceSettingsViewController else {
                fatalError("Unexpected destination view controller")
            }
            
            // Pass the existing device to the health view controller
            setVC.device = self.device
        }
    }

    // Rest of your existing code...
}
