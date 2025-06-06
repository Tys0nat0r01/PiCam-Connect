//
//  PiCamSetupPairing.swift
//  PiCam
//
//  Created by Tyson Miles on 12/4/2025.
//
import UIKit
import Network
import NetworkExtension
import Firebase
import FirebaseFirestore
import FirebaseAuth

class PiCamSetupPairing: UIViewController {
    let hotspotManager = HotspotManager()
    private let spinner = UIActivityIndicatorView(style: .medium)
    var piConnection: NWConnection?
    let piAddress = "192.168.4.1"
    let piPort: Network.NWEndpoint.Port = 4545
    var deviceName: String?
    var serialNumber: String?
    var deviceDocNum: String?
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceSerialLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceNameLabel.text = "Pair with \(deviceName ?? "Device")?"
        deviceSerialLabel.text = serialNumber
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        let alert = MidAlertView(
            type: .loadingcustom,
            title: "Just a moment",
            message: "",
            symbol: UIImage(named: "loadingspinner")
        )
        alert.show(in: view, duration: 0.3)
        
        dismiss(animated: true)
    }
    @IBAction func PairButtonTapped(_ sender: UIButton) {
        guard Auth.auth().currentUser != nil else {
            showAuthAlert()
            return
        }
        let alert = MidAlertView(
            type: .loadingcustom,
            title: "Connecting to your PiCam",
            message: "This may take a moment",
            symbol: UIImage(named: "loadingspinner")
            )
        
        alert.show(in: view, duration: 3)
            connectToPiServer()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let self = self else { return }
                if self.piConnection?.state != .ready {
                    alert.dismiss()
                    self.showConnectionError(NSError(domain: "", code: 408, userInfo: [NSLocalizedDescriptionKey: "Connection timeout"]),
                                             ssid: self.deviceName ?? "Device",
                                             devicename: self.deviceName ?? "Device")
                }
            }
    }
    func getDocumentFromDocID(documentID: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        guard let currentUser = Auth.auth().currentUser else {
            showAuthAlert()
            return
        }
        
        db.collection("devices").whereField("documentID", isEqualTo: documentID).getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                self?.showFirebaseError(error)
                completion(error)
                return
            }
            
            guard let document = snapshot?.documents.first else {
                self?.showInvalidSerialAlert()
                completion(NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found"]))
                return
            }
            
            // Update the useruid field in the document
            document.reference.updateData(["useruid": currentUser.uid]) { [weak self] error in
                if let error = error {
                    self?.showRegistrationError(error)
                    completion(error)
                    return
                }
                
                // Show success alert
                self?.showRegistrationSuccess(devicename: self?.deviceName ?? "Device")
                completion(nil)
            }
        }
    }
    
    private func showConnectionError(_ error: Error, ssid: String, devicename: String) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: 0.5)
        let alert = MidAlertView(
            type: .alert,
            title: "Unable to Connect",
            message: "An error occured while connecting to \(devicename). Please try again later, or post an issue on our GitHub if this issue persists. The error was: \(error.localizedDescription)",
            symbol: UIImage(systemName: "exclamationmark.circle.fill"),
            primaryAction: { print("insert action") },
            primaryActionName: "OK",
            primaryActionColor: .systemBlue
        )
        
        alert.show(in: view)
    }
    private func showRegistrationSuccess(devicename: String) {
        let alert = MidAlertView(
            type: .success,
            title: "Registered \(devicename)!",
            message: "Your PiCam is now registered to your PiCam Connect account.",
            symbol: UIImage(systemName: "checkmark.circle.fill"))
        alert.show(in: view, duration: 2)
    }
    private func showConnectionSuccess(ssid: String) {
        let alert = MidAlertView(
            type: .success,
            title: "Connected!",
            message: "Connected to \(ssid)",
            symbol: UIImage(systemName: "checkmark.circle.fill"))
        alert.show(in: view, duration: 3)
    }
    private func showAuthAlert() {
        let alert = MidAlertView(
            type: .alert,
            title: "Not Signed In",
            message: "Sign In to your PiCam Connect account to continue",
            symbol: UIImage(systemName: "person.crop.circle.badge.questionmark.fill"),
            primaryAction: { print("insert action") },
            primaryActionName: "OK",
            primaryActionColor: .systemBlue
        )
        
        alert.show(in: view)
    }
    private func showDeviceDetailsMissingAlert() {
        let alert = MidAlertView(
            type: .alert,
            title: "An Internal Error Occurred",
            message: "Our records show that the details required to setup and connect to your device are missing. Please check our forums for more information.",
            symbol: UIImage(systemName: "questionmark.text.page.fill"),
            primaryAction: { print("insert action") },
            secondaryActionName: "Learn More",
            primaryActionName: "OK",
            primaryActionColor: .systemBlue,
            secondaryActionColor: .systemGray,
            secondaryAction: { print("insert action")},
        )
        
        alert.show(in: view)
    }
    private func showRegistrationError(_ error: Error) {
        let alert = MidAlertView(
            type: .alert,
            title: "Could Not Connect",
            message: "\(error.localizedDescription)",
            symbol: UIImage(systemName: "person.crop.circle.badge.exclamationmark.fill"),
            primaryAction: { /* action */ },
            secondaryActionName: "Learn More",
            primaryActionName: "OK",
            primaryActionColor: .systemBlue,
            secondaryActionColor: .systemGray,
            secondaryAction: {
                self.showErrorAlert(message: "{INSERT ACTION}")
            }
        )
        alert.show(in: view)
        print( "Missing WiFi credentials in device record")
    }
    
    private func showFirebaseError(_ error: Error) {
        let alert = MidAlertView(
            type: .success,
            title: "An Error Occurred",
            message: error.localizedDescription,
            symbol: UIImage(systemName: "exclamationmark.circle.fill"))
        alert.show(in: view, duration: 6)
    }
    
    private func showInvalidSerialAlert() {
        let alert = MidAlertView(
            type: .alert,
            title: "An Error Occured",
            message: "There are no currently active devices that have this serial number. Try again, or check our forums for more infomration.",
            symbol: UIImage(systemName: "exclamationmark.circle.fill"),
            primaryAction: {
                self.showErrorAlert(message: "INSERT ACTION")
            },
            primaryActionName: "OK",
            primaryActionColor: .systemBlue
        )
        alert.show(in: view)
    }
    private func showMissingCredentialsAlert() {
        let alert = MidAlertView(
            type: .alert,
            title: "Could Not Connect",
            message: "Our records show that this device has not been equipped with WiFi capability. Check our forums for more information.",
            symbol: UIImage(systemName: "person.crop.circle.badge.exclamationmark.fill"),
            primaryAction: { /* action */ },
            secondaryActionName: "Learn More",
            primaryActionName: "OK",
            primaryActionColor: .systemBlue,
            secondaryActionColor: .systemGray,
            secondaryAction: {
                self.showErrorAlert(message: "{INSERT ACTION}")
            }
        )
        alert.show(in: view)
        print( "Missing WiFi credentials in device record")
    }
    
    private func showDeviceAlreadyRegisteredAlert() {
        let alert = MidAlertView(
            type: .alert,
            title: "Unable to Register Device",
            message: "This device is already registered to you. Remove the device from your account to set it up again.",
            symbol: UIImage(systemName: "person.crop.circle.badge.exclamationmark.fill"),
            primaryAction: { /* action */ },
            secondaryActionName: "Learn More",
            primaryActionName: "OK",
            primaryActionColor: .systemBlue,
            secondaryActionColor: .systemGray,
            secondaryAction: {
                self.showErrorAlert(message: "Removing Device...")
            }
        )
        alert.show(in: view)
    }
    private func showDeviceRegisteredToOtherAlert() {
        let alert = MidAlertView(
            type: .alert,
            title: "Unable to Register Device",
            message: "This device is registered to someone else. If your beileve this is a mistake, please contact support.",
            symbol: UIImage(systemName: "person.crop.circle.badge.questionmark.fill"),
            primaryAction: { /* action */ },
            secondaryActionName: "Learn More",
            primaryActionName: "OK",
            primaryActionColor: .systemBlue,
            secondaryActionColor: .systemGray,
            secondaryAction: {
                self.showErrorAlert(message: "Removing Device...")
            }
        )
        alert.show(in: view)
    }
    
    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
    func connectToPiServer() {
        let host = NWEndpoint.Host(piAddress)
        let port = NWEndpoint.Port(rawValue: piPort.rawValue)!
        piConnection = NWConnection(host: host, port: port, using: .tcp)
        piConnection?.stateUpdateHandler = { [weak self] newState in
            switch newState {
            case .ready:
                self?.sendSerialRequest()
            case .failed(let error):
                print("Connection failed: \(error)")
                self?.showConnectionError(error, ssid: self?.deviceName ?? "Device", devicename: self?.deviceName ?? "Device")
            default: break
            }
        }
        
        piConnection?.start(queue: .main)
    }
    
    private func sendSerialRequest() {
        let message = "sendserialnumber"
        piConnection?.send(content: message.data(using: .utf8), completion: .contentProcessed { error in
            if let error = error {
                print("Send error: \(error)")
                return
            }
            self.receiveSerial()
        })
    }
    
    // Update receiveSerial function
    private func receiveSerial() {
        piConnection?.receive(minimumIncompleteLength: 1, maximumLength: 100) { [weak self] data, _, isComplete, error in
            guard let data = data, let serial = String(data: data, encoding: .utf8) else { return }
            
            if self?.serialNumber == serial {
                self?.verifySerialWithFirebase(serial: serial)
            } else {
                let alert = MidAlertView(
                    type: .alert,
                    title: "A Verification Error Occurred",
                    message: "The serial number received from your PiCam during setup does not match the one that you have entered. If you believe this is a mistake, please contact support.",
                    symbol: UIImage(systemName: "exclamationmark.circle.fill"),
                    primaryAction: { print("insert action") },
                    secondaryActionName: "Learn More",
                    primaryActionName: "OK",
                    primaryActionColor: .systemBlue,
                    secondaryActionColor: .systemGray,
                    secondaryAction: { print("insert action") }
                )
                alert.show(in: self!.view!)
            }
        }
    }

    private func verifySerialWithFirebase(serial: String) {
        let db = Firestore.firestore()
        db.collection("devices").whereField("serialnumber", isEqualTo: serial).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showFirebaseError(error)
                return
            }
            
            guard let document = snapshot?.documents.first else {
                self.showInvalidSerialAlert()
                return
            }
            
            if let existingUser = document.data()["useruid"] as? String, !existingUser.isEmpty {
                showAuthAlert()
            } else {
                self.performHealthCheck()
            }
        }
    }
    // Add after receiveSerial function
    private func performHealthCheck() {
        sendHealthCheckCommand()
    }

    private func sendHealthCheckCommand() {
        let message = "performHealthCheck"
        piConnection?.send(content: message.data(using: .utf8), completion: .contentProcessed { error in
            if let error = error {
                print("Health check send error: \(error)")
                let alert = MidAlertView(
                    type: .alert,
                    title: "An Error Occured",
                    message: "An error occured while perfoming a health check on your PiCam. Please try again later read our documentation for more information.",
                    symbol: UIImage(systemName: "questionmark.text.page.fill"),
                    primaryAction: { print("insert action") },
                    secondaryActionName: "Learn More",
                    primaryActionName: "OK",
                    primaryActionColor: .systemBlue,
                    secondaryActionColor: .systemGray,
                    secondaryAction: { print("insert action")},
                )
                
                alert.show(in: self.view)
                return
            }
            self.receiveHealthCheckResults()
        })
    }

    private func receiveHealthCheckResults() {
        piConnection?.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] data, _, isComplete, error in
            guard let data = data else {
                let alert = MidAlertView(
                    type: .alert,
                    title: "An Error Occured",
                    message: "An error occured while perfoming a health check on your PiCam. Please try again later read our documentation for more information.",
                    symbol: UIImage(systemName: "questionmark.text.page.fill"),
                    primaryAction: { print("insert action") },
                    secondaryActionName: "Learn More",
                    primaryActionName: "OK",
                    primaryActionColor: .systemBlue,
                    secondaryActionColor: .systemGray,
                    secondaryAction: { print("insert action")},
                )
                
                alert.show(in: self!.view)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(HealthCheckResponse.self, from: data)
                if !result.errors.isEmpty {
                    self?.handleHealthCheckErrors(errors: result.errors)
                } else {
                    self?.proceedToPairing()
                }
            } catch {
                let alert = MidAlertView(
                    type: .alert,
                    title: "An Error Occured",
                    message: "An error occured while perfoming a health check on your PiCam. Please try again later read our documentation for more information.",
                    symbol: UIImage(systemName: "questionmark.text.page.fill"),
                    primaryAction: { print("insert action") },
                    secondaryActionName: "Learn More",
                    primaryActionName: "OK",
                    primaryActionColor: .systemBlue,
                    secondaryActionColor: .systemGray,
                    secondaryAction: { print("insert action")},
                )
                
                alert.show(in: self!.view)
            }
        }
    }

    private func proceedToPairing() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "GotoPairingPage", sender: self)
        }
    }

    private func handleHealthCheckErrors(errors: [String]) {
        let errorMessages = errors.joined(separator: "\n• ")
        let alert = MidAlertView(
            type: .alert,
            title: "Device Health Check Failed",
            message: "Found issues:\n• \(errorMessages)",
            symbol: UIImage(systemName: "exclamationmark.triangle.fill"),
            primaryAction: { self.dismiss(animated: true) },
            primaryActionName: "OK",
            primaryActionColor: .systemRed
        )
        DispatchQueue.main.async {
            alert.show(in: self.view)
        }
    }

    // Add at bottom of the class
    struct HealthCheckResponse: Codable {
        let status: String
        let errors: [String]
    }
}
