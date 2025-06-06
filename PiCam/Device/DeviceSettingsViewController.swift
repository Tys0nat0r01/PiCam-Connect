//
//  DeviceHealthViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 15/4/2025.
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class DeviceSettingsViewController: UITableViewController {
    
    // MARK: - Properties
    var device: Device!
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    // MARK: - Outlet
    @IBOutlet weak var SettingsDeviceNameInput: UITextField!
    @IBOutlet weak var SettingsWiFiSSIDInput: UITextField!
    @IBOutlet weak var SettingsFileLengthInput: UISegmentedControl!
    @IBOutlet weak var SettingsFileDeletionInput: UISegmentedControl!
    @IBOutlet weak var SettingsFileDeletionControl: UISwitch!
    @IBOutlet weak var SettingsGuardModeControl: UISwitch!
    @IBAction func RemoveDevicePressed(_ sender: UIButton!) {
        removeDevice()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
            super.viewDidLoad()
            assert(device != nil, "Device must be set before presentation")
            setupRealTimeUpdates()
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    
    // MARK: - Setup
    private func setupUI() {
       
        //let formatter = DateFormatter()
         //       formatter.dateStyle = .medium
          //      formatter.timeStyle = .short
          //      HealthlastUpdated?.text = formatter.string(from: device.la)
            }
            
    // MARK: - Real Time Updates
    private func setupRealTimeUpdates() {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        listener = db.collection("devices")
            .document(device.serialnum) // Direct document reference
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.showErrorAlert(message: error.localizedDescription)
                    return
                }
                
                guard let document = snapshot else {
                    self.showErrorAlert(message: "Device no longer exists")
                    return
                }
                
                self.updateDeviceData(with: document)
            }
    }
    
    private func updateDeviceData(with document: DocumentSnapshot) {
        guard let data = document.data() else { return }
        
        let updatedDevice = Device(
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
        
        device = updatedDevice
        setupUI() // Refresh all UI elements
    }
    func removeDevice() {
        let alert = MidAlertView(
            type: .alert,
            title: "Remove Device",
            message: "Are you sure you want to remove \(device.devicename) from your account? You will need to re-setup this device to use it again.",
            symbol: UIImage(systemName: "exclamationmark.circle.fill"),
            primaryAction: {
                self.db.collection("devices").document().updateData(["useruid": ""]) { error in
                    if let error = error {
                        self.showErrorAlert(message: error.localizedDescription)
                    } else {
                        self.showErrorAlert(message: "Device removed successfully.")
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            },
            secondaryActionName: "Cancel",
            primaryActionName: "Remove Device",
            primaryActionColor: .systemRed,
            secondaryActionColor: .systemGray,
            secondaryAction: {}
        )
        
        alert.show(in: view)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
