//
//  BluetoothViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 16/2/2025.
//

import UIKit
import CoreBluetooth

class BluetoothViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!  // Add Next button outlet

    var centralManager: CBCentralManager!
    var piCamPeripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial UI setup
        titleLabel.text = "Searching..."
        subtitleLabel.text = "This may take a while"
        
        // Hide all buttons initially except Help
        yesButton.isHidden = true
        noButton.isHidden = true
        helpButton.isHidden = false
        tryAgainButton.isHidden = true
        nextButton.isHidden = true  // Initially hide Next button
        
        // Initialize Bluetooth Central Manager
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Bluetooth State Change
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is ON. Scanning for PiCam...")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth is OFF. Please enable it.")
            titleLabel.text = "Could Not Connect"
            subtitleLabel.text = "Please enable Bluetooth in Settings > Bluetooth"
            helpButton.isHidden = false
            tryAgainButton.isHidden = false
        }
    }
    
    // MARK: - Discover PiCam
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, name.contains("PiCam") {
            print("Found \(name)! Asking for confirmation...")

            // Stop scanning once PiCam is found
            centralManager.stopScan()
            
            // Save peripheral
            piCamPeripheral = peripheral
            piCamPeripheral?.delegate = self
            
            // Update UI for user confirmation
            titleLabel.text = "Is this your PiCam?"
            subtitleLabel.text = name // Show PiCam name
            yesButton.isHidden = false
            noButton.isHidden = false
            helpButton.isHidden = true
            tryAgainButton.isHidden = true
        }
    }
    
    // MARK: - Handle Successful Connection
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to PiCam!")
        
        if let peripheralName = peripheral.name {
            UserDefaults.standard.set(peripheralName, forKey: "SavedPiCamName")
        }
        
        titleLabel.text = "Connected"
        subtitleLabel.text = "Press next to continue"
        yesButton.isHidden = true
        noButton.isHidden = true
        helpButton.isHidden = true
        tryAgainButton.isHidden = true
        nextButton.isHidden = false  // Show the Next button when connected
    }
    
    // MARK: - Handle Connection Failure
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
        titleLabel.text = "Could Not Connect"
        subtitleLabel.text = "Ensure your PiCam is powered on and nearby."
        yesButton.isHidden = true
        noButton.isHidden = true
        helpButton.isHidden = true
        tryAgainButton.isHidden = false  // Show Try Again button
    }
    
    // MARK: - Handle Disconnection
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from PiCam.")
    }
    
    // MARK: - Button Actions
    
    // Yes Button - Pair with PiCam
    @IBAction func yesButtonTapped(_ sender: UIButton) {
        if let piCamPeripheral = piCamPeripheral {
            centralManager.connect(piCamPeripheral, options: nil)
            
            titleLabel.text = "Connecting..."
            subtitleLabel.text = "A prompt to connect with your PiCam may display, press 'Yes' to continue"
            
            yesButton.isHidden = true
            noButton.isHidden = true
            helpButton.isHidden = true
            tryAgainButton.isHidden = true
            nextButton.isHidden = true
        }
    }

    
    
    // Help Button - Show helpful information
    @IBAction func helpButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Help", message: "Ensure PiCam is powered on and nearby", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Try Again Button - Retry scanning for PiCam
    @IBAction func tryAgainButtonTapped(_ sender: UIButton) {
        titleLabel.text = "Searching..."
        subtitleLabel.text = "This may take a while"
        yesButton.isHidden = true
        noButton.isHidden = true
        helpButton.isHidden = false
        tryAgainButton.isHidden = true
        
        centralManager.scanForPeripherals(withServices: nil, options: nil) // Retry scanning
    }
    
    // Next Button - Proceed to the next step
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        // You can add the code to move to the next screen or do any action you want
        print("Next button pressed! Proceeding to the next step...")
        // Example: Navigate to another screen
        // self.performSegue(withIdentifier: "goToNextScreen", sender: self)
    }
}
