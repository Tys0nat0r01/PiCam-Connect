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

class DeviceHealthViewController: UITableViewController {
    
    // MARK: - Properties
    var device: Device!
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    // MARK: - Outlet
    @IBOutlet weak var HealthserialNumberLabel: UILabel!
    @IBOutlet weak var HealthdeviceNameLabel: UILabel!
    @IBOutlet weak var HealthmodelNumberLabel: UILabel!
    @IBOutlet weak var HealthvideoHoursLabel: UILabel!
    @IBOutlet weak var HealthStatusLabel: UILabel!
    @IBOutlet weak var HealthlastSeen: UILabel!
    @IBOutlet weak var HealthlastUpdated: UILabel!
    @IBOutlet weak var statusimage: UIImageView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
            super.viewDidLoad()
            assert(device != nil, "Device must be set before presentation")
            setupUI()
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
        HealthserialNumberLabel.text = device.serialnum
        HealthdeviceNameLabel.text = device.devicename
        HealthmodelNumberLabel.text = device.modelnum
        HealthvideoHoursLabel.text = "\(device.videohours) hours"
        HealthStatusLabel.text = device.status
        if device.status == "Recording" {
            statusimage.removeAllSymbolEffects()
            statusimage.image = UIImage(systemName: "record.circle.fill")
            statusimage.tintColor = .systemRed
            statusimage.addSymbolEffect(.pulse.wholeSymbol, options: .repeat(.periodic(delay: 0.0)))
        }
        if device.status == "Idle" {
            statusimage.removeAllSymbolEffects()
            statusimage.image = UIImage(systemName: "clock.circle.fill")
            statusimage.tintColor = .secondaryLabel
        }
        if device.status == "Unknown" {
            statusimage.removeAllSymbolEffects()
            statusimage.image = UIImage(systemName: "questionmark.circle.fill")
            statusimage.tintColor = .secondaryLabel
        }
        if device.status == "Not Recording" {
            statusimage.removeAllSymbolEffects()
            statusimage.image = UIImage(systemName: "exclamationmark.triangle.fill")
            statusimage.tintColor = .systemYellow
            statusimage.addSymbolEffect(.pulse.wholeSymbol, options: .repeat(.periodic(delay: 0.0)))
        }
        if device.status == "Updating" {
            statusimage.removeAllSymbolEffects()
            statusimage.image = UIImage(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
            statusimage.tintColor = .secondaryLabel
            statusimage.addSymbolEffect(.rotate.byLayer, options: .repeat(.periodic(delay: 0.0)))
            //let formatter = DateFormatter()
            //       formatter.dateStyle = .medium
            //      formatter.timeStyle = .short
            //      HealthlastUpdated?.text = formatter.string(from: device.la)
        }
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
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
