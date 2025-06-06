//
//  deviceViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 16/2/2025.
//
import UIKit

class DeviceViewController: UIViewController {
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var chipLabel: UILabel!
    @IBOutlet weak var videoHoursLabel: UILabel!
    @IBOutlet weak var softwareLabel: UILabel!
    @IBOutlet weak var visibilitySwitch: UISwitch!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var recordingDurationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var autoDeleteDurationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var wifiSSIDTextField: UITextField!

    let bluetoothManager = BluetoothManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bluetoothManager.onDeviceAttributesReceived = { attributes in
            DispatchQueue.main.async {
                self.modelLabel.text = attributes["model"]
                self.deviceNameLabel.text = attributes["device_name"]
                self.serialLabel.text = attributes["serial"]
                self.chipLabel.text = attributes["chip"]
                self.videoHoursLabel.text = attributes["video_hours"]
                self.softwareLabel.text = attributes["software_version"]
            }
        }
        // Initially set the visibility of the segmented control based on the switch's state
        updateSegmentedControlVisibility()
    }
    
    // Action for the switch's value change
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        // Call the function to update the visibility
        updateSegmentedControlVisibility()
    }
    
    // Function to update the visibility of the segmented control
    private func updateSegmentedControlVisibility() {
        // Check the state of the switch
        if visibilitySwitch.isOn {
            // If the switch is ON, show the segmented control
            segmentedControl.isHidden = false
        } else {
            // If the switch is OFF, hide the segmented control
            segmentedControl.isHidden = true
        }
    }
    @IBAction func recordingDurationChanged(_ sender: UISegmentedControl) {
        print("Hello")
        // Handle the selected option for recording duration
    }

    @IBAction func autoDeleteDurationChanged(_ sender: UISegmentedControl) {
        print("Hello")
        // Handle the selected option for auto delete duration
    }
    @IBAction func wifiSSIDTextChanged(_ sender: UITextField) {
        print("Hello")
            // Handle the SSID input
        }
    }



