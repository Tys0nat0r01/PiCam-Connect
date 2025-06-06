//
//  BluetoothManager 2.swift
//  PiCam
//
//  Created by Tyson Miles on 16/2/2025.
//


import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    protocol BluetoothManagerDelegate: AnyObject {
        func didUpdateConnectedDevice(name: String)
    }

    var centralManager: CBCentralManager!
    weak var delegate: BluetoothManagerDelegate?
    var raspberryPi: CBPeripheral?
    var deviceAttributesCharacteristic: CBCharacteristic?
    var videoFileCharacteristic: CBCharacteristic?
    
    var onDeviceAttributesReceived: (([String: String]) -> Void)?
    var onVideoFilesReceived: (([String]) -> Void)?
    var connectedDeviceName: String? {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.didUpdateConnectedDevice(name: self.connectedDeviceName ?? "No Device")
            }
        }
    }
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name?.contains("PiCam") == true {
            centralManager.stopScan()
            raspberryPi = peripheral
            raspberryPi?.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        connectedDeviceName = peripheral.name  // Store device name
        delegate?.didUpdateConnectedDevice(name: peripheral.name ?? "Unknown Device")
    }

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: "1234ABCD-5678-90EF-1234-567890ABDFEF") {
                deviceAttributesCharacteristic = characteristic
                peripheral.readValue(for: characteristic)
            } else if characteristic.uuid == CBUUID(string: "4321DCBA-8765-FE09-4321-098765FEDCBA") {
                videoFileCharacteristic = characteristic
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic == deviceAttributesCharacteristic, let data = characteristic.value {
            if let jsonString = String(data: data, encoding: .utf8),
               let attributes = try? JSONDecoder().decode([String: String].self, from: jsonString.data(using: .utf8)!) {
                onDeviceAttributesReceived?(attributes)
            }
        } else if characteristic == videoFileCharacteristic, let data = characteristic.value {
            if let jsonString = String(data: data, encoding: .utf8),
               let fileList = try? JSONDecoder().decode([String].self, from: jsonString.data(using: .utf8)!) {
                onVideoFilesReceived?(fileList)
            }
        }
    }
    
    func sendUpdatedAttributes(_ attributes: [String: String]) {
        guard let characteristic = deviceAttributesCharacteristic else { return }
        if let jsonData = try? JSONEncoder().encode(attributes) {
            raspberryPi?.writeValue(jsonData, for: characteristic, type: .withResponse)
        }
    }
    
    func sendCommand(_ command: String) {
        guard let characteristic = videoFileCharacteristic, let peripheral = raspberryPi else { return }
        if let commandData = command.data(using: .utf8) {
            peripheral.writeValue(commandData, for: characteristic, type: .withResponse)
        }
    }
}

