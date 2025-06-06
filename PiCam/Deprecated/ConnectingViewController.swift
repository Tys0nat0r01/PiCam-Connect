//
//  ConnectingViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 17/2/2025.
//
import UIKit
import CoreBluetooth

class ConnectingViewController: UIViewController, CBCentralManagerDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!

    var centralManager: CBCentralManager!
    var savedPiCamName: String?
    var discoveredPeripheral: CBPeripheral?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.isHidden = true  // Hide error message initially
        activityIndicator.startAnimating()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Retrieve previously saved PiCam name (stored in UserDefaults)
        savedPiCamName = UserDefaults.standard.string(forKey: "SavedPiCamName")
        
        if savedPiCamName == nil {
            showError(message: "No saved devices found")
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Start scanning for the saved PiCam name
            if let piCamName = savedPiCamName {
                statusLabel.text = "Searching for \(piCamName)..."
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
        } else {
            showError(message: "Bluetooth is Disabled. Please enable it in Settings > Bluetooth")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, name == savedPiCamName {
            print("Found saved PiCam: \(name)")
            centralManager.stopScan()
            statusLabel.text = "Connecting to \(name)..."
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        activityIndicator.stopAnimating()
        statusLabel.text = "Connected to \(peripheral.name ?? "PiCam") "
        errorLabel.isHidden = true
        dismissAfterDelay()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        showError(message: "Could Not Connect")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        showError(message: "Connection Lost")
    }
    
    func showError(message: String) {
        activityIndicator.stopAnimating()
        statusLabel.text = "Error"
        errorLabel.isHidden = false
        errorLabel.text = message
    }
    
    func dismissAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
