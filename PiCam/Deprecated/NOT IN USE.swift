//
//  BluetoothManager.swift
//  PiCam
//
//  Created by Tyson Miles on 15/2/2025.
//


import CoreBluetooth

class DeviceManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?

    var savedDevicesAttributes: [String: [String: String]] = [:] {
        didSet {
            saveAttributesToStorage()
        }
    }
    
    var selectedDeviceID: String? {
        didSet {
            saveSelectedDevice()
        }
    }

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        loadAttributesFromStorage()
        loadSelectedDevice()
    }

    // Save attributes for multiple devices
    private func saveAttributesToStorage() {
        UserDefaults.standard.set(savedDevicesAttributes, forKey: "SavedDevicesAttributes")
    }

    // Load saved attributes
    private func loadAttributesFromStorage() {
        if let savedAttributes = UserDefaults.standard.dictionary(forKey: "SavedDevicesAttributes") as? [String: [String: String]] {
            self.savedDevicesAttributes = savedAttributes
        }
    }

    // Save selected device ID
    private func saveSelectedDevice() {
        UserDefaults.standard.set(selectedDeviceID, forKey: "SelectedDeviceID")
    }

    // Load selected device ID
    private func loadSelectedDevice() {
        selectedDeviceID = UserDefaults.standard.string(forKey: "SelectedDeviceID")
    }

    func updateAttributes(for deviceID: String, attributes: [String: String]) {
        savedDevicesAttributes[deviceID] = attributes
        selectedDeviceID = deviceID // Auto-select this device when updating attributes
    }

    func clearSavedDevices() {
        UserDefaults.standard.removeObject(forKey: "SavedDevicesAttributes") // Remove all saved attributes
        UserDefaults.standard.removeObject(forKey: "SelectedDeviceID") // Remove selected device
        savedDevicesAttributes.removeAll()
        selectedDeviceID = nil
    }
}
