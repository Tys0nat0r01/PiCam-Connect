//
//  DeviceSelectionViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 10/5/2025.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

class DeviceSelectionViewController: UIViewController {
    
    // List of devices to select from
    var devices: [Device] = []
    private let db = Firestore.firestore()
    
    @IBOutlet weak var devicePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        devicePicker.dataSource = self
        devicePicker.delegate = self
        fetchDevices()
    }
    
    private func fetchDevices() {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("devices")
            .whereField("useruid", isEqualTo: userUID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching devices: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.devices = documents.compactMap { doc -> Device? in
                    let data = doc.data()
                    return Device(
                        useruid: data["useruid"] as? String ?? "",
                        serialnum: data["serialnum"] as? String ?? "",
                        devicename: data["devicename"] as? String ?? "",
                        modelnum: data["modelnum"] as? String ?? "",
                        videohours: data["videohours"] as? Int ?? 0,
                        activated: data["activated"] as? Bool ?? false,
                        lastseen: (data["lastseen"] as? Timestamp)?.dateValue() ?? Date(),
                        friendlyname: data["wifi_ssid"] as? String ?? "",
                        wifipassword: data["wifi_password"] as? String ?? "",
                        wifissid: data["friendlyname"] as? String ?? "",
                        status: data["status"] as? String ?? ""
                    )
                }
                
                DispatchQueue.main.async {
                    self.devicePicker.reloadAllComponents()
                }
            }
    }
    
    @IBAction func saveSelectedDevice(_ sender: UIBarButtonItemGroup) {
        let selectedRow = devicePicker.selectedRow(inComponent: 0)
        let selectedDevice = devices[selectedRow]
        
        // Save the selected device to UserDefaults
        Core.shared.setCurrentDeviceName(selectedDevice.devicename)
        Core.shared.saveDeviceDetails(selectedDevice)
        
        print("Selected device: \(selectedDevice.devicename)")
        
        
    }
}

extension DeviceSelectionViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return devices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return devices[row].devicename
    }
}
