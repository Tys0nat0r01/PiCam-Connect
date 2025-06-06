//
//  PiCamSetupConfirmation.swift
//  PiCam
//
//  Created by Tyson Miles on 10/4/2025.
//
import UIKit
import Network
import FirebaseFirestore
import FirebaseAuth
import NetworkExtension

class PiCamSetupConfirmation: UIViewController {
    let hotspotManager = HotspotManager()
    private let spinner = UIActivityIndicatorView(style: .medium)
    var piConnection: NWConnection?
    let piAddress = "192.168.4.1"
    let piPort: Network.NWEndpoint.Port = 4545
    var ssidInfo: String?
    var deviceName: String?
    var passwordInfo: String?
    var serialNumber: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        cancelSetup()
    }
    func cancelSetup() {
        let alert = MidAlertView(
            type: .alert,
            title: "Exit Setup",
            message: "Are you sure you would like to exit setup? You will have to repeat this process again if you change your mind.",
            symbol: UIImage(systemName: "exclamationmark.circle.fill"),
            primaryAction: {
                self.dismiss(animated: true)
            },
            secondaryActionName: "Continue Setup",
            primaryActionName: "Exit Setup",
            primaryActionColor: .systemGray,
            secondaryActionColor: .systemBlue,
            secondaryAction: {
            },
        )
        
        alert.show(in: view)
    }
    func claimDevice(document: QueryDocumentSnapshot, forUser user: User, ssid: String, password: String, devicename: String) {
        document.reference.updateData(["useruid": user.uid]) { [weak self] error in
            if let error = error {
                self?.showRegistrationError(error)
                return
            }
            self?.handleWiFiCredentials(ssid: ssid, password: password, devicename: devicename)
        }
    }
    
    // MARK: - WiFi Handling'
    
    func handleWiFiCredentials(ssid: String, password: String, devicename: String) {
        let alert = MidAlertView(
            type: .loading,
            title: "Connecting to \(devicename)",
            message: ""
        )
        alert.show(in: view)
        connectToWiFiNetwork(ssid: ssid, password: password, devicename: devicename)
    }
    
    func connectToWiFiNetwork(ssid: String, password: String, devicename: String) {
        let configuration = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
        NEHotspotConfigurationManager.shared.apply(configuration) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showConnectionError(error, ssid: ssid, devicename: devicename)
                } else {
                    self?.showConnectionSuccess(ssid: ssid)
                }
            }
        }
    }
    func showAuthAlert() {
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
    func showDeviceDetailsMissingAlert() {
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
    func showRegistrationError(_ error: Error) {
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
    
    func showFirebaseError(_ error: Error) {
        let alert = MidAlertView(
            type: .success,
            title: "An Error Occurred",
            message: error.localizedDescription,
            symbol: UIImage(systemName: "exclamationmark.circle.fill"))
        alert.show(in: view, duration: 6)
    }
    
    func showInvalidSerialAlert() {
        let alert = MidAlertView(
            type: .success,
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
    func showMissingCredentialsAlert() {
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
    
    func showConnectionError(_ error: Error, ssid: String, devicename: String) {
        let alert = MidAlertView(
            type: .alert,
            title: "Unable to Connect",
            message: "An error occured while connecting to \(devicename). The error was: \(error.localizedDescription)",
            symbol: UIImage(systemName: "exclamationmark.circle.fill"),
            primaryAction: { print("insert action") },
            primaryActionName: "OK",
            primaryActionColor: .systemBlue
        )
        
        alert.show(in: view)
    }
    func showConnectionSuccess(ssid: String) {
        let alert = MidAlertView(
            type: .success,
            title: "Connected!",
            message: "Connected to \(ssid)",
            symbol: UIImage(systemName: "checkmark.circle.fill"))
        alert.show(in: view, duration: 3)
    }
    func showDeviceAlreadyRegisteredAlert() {
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
    func showDeviceRegisteredToOtherAlert() {
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
}
