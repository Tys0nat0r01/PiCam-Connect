//
//  PiCamSetupHotspot.swift
//  PiCam
//
//  Created by Tyson Miles on 12/4/2025.
//
import UIKit
import Network
import CoreLocation
import NetworkExtension
import Firebase
import FirebaseFirestore

class PiCamSetupHotspot: UIViewController {
    var ssidInfo: String?
    var passwordInfo: String?
    var deviceName: String?
    var serialNumber: String?
    var deviceDocNum: String?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    let hotspotManager = HotspotManager()
    
    @IBAction func okButtonTapped(_ sender: UIButton) {
        guard let ssid = ssidInfo, let password = passwordInfo, let devicename = deviceName, let deviceDocnum = deviceDocNum, let serialNumber = serialNumber else {
            print("Missing required information to connect to the hotspot.")
            return
        }
        let alert = MidAlertView(
            type: .loadingcustom,
            title: nil,  // Ignored
            message: "",  // Ignored
            symbol: UIImage(named: "loadingspinner")
        )
        alert.show(in: view, duration: 3)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.hotspotManager.connectToHotspot(ssid: ssid, password: password) { [self] success in
                if success {
                    DispatchQueue.main.async {
                        self?.showConnectionSuccess(devicename: devicename)
                        self?.proceedToConfirmationPage(devicename: devicename, serialNumber: serialNumber, deviceDocNum: deviceDocnum)
                    }
                } else {
                    self?.proceedToHotspotManualPage(deviceDocNum: deviceDocnum, devicename: devicename, serialNumber: serialNumber, password: password, ssid: ssid)
                    // self.showConnectionSuccess(devicename: devicename)
                    //self.proceedToConfirmationPage(devicename: devicename, serialNumber: serialNumber, deviceDocNum: deviceDocnum)
                    DispatchQueue.main.async {
                        let alert = MidAlertView(
                            type: .alert,
                            title: "A Fatal Error Occurred",
                            message: "PiCam Connect requires Network Extension and HOTSPOT entitlement. If you see this error, please contact support, or add an issue to our GitHub repository immediately. ER: CL-928",
                            symbol: UIImage(systemName: "laptopcomputer.trianglebadge.exclamationmark"),
                            primaryAction: { print("insert action") },
                            primaryActionName: "OK",
                            primaryActionColor: .systemBlue
                        )
                        
                        alert.show(in: self!.view)
                        self!.showConnectionError(ssid: ssid, devicename: devicename)
                        alert.dismiss()
                    }
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        cancelSetup()
    }
    
    private func showConnectionError(ssid: String, devicename: String) {
        let alert = MidAlertView(
            type: .alert,
            title: "Unable to Connect",
            message: "An error occurred while connecting to \(devicename). Please try again.",
            symbol: UIImage(systemName: "exclamationmark.circle.fill"),
            primaryAction: { print("insert action") },
            primaryActionName: "OK",
            primaryActionColor: .systemBlue
        )
        
        alert.show(in: view)
    }
    
    private func showConnectionSuccess(devicename: String) {
        let alert = MidAlertView(
            type: .success,
            title: "Connected!",
            message: "Connected to \(devicename)",
            symbol: UIImage(systemName: "checkmark.circle.fill")
        )
        alert.show(in: view, duration: 3)
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
            secondaryAction: {}
        )
        
        alert.show(in: view)
    }
    
    private func proceedToConfirmationPage(devicename: String, serialNumber: String, deviceDocNum: String) {
        let destVC = storyboard?.instantiateViewController(withIdentifier: "PiCamSetupPairing") as! PiCamSetupPairing
        destVC.deviceDocNum = deviceDocNum
        destVC.deviceName = devicename
        destVC.serialNumber = serialNumber
        destVC.modalPresentationStyle = .formSheet
        destVC.modalTransitionStyle = .coverVertical
        self.present(destVC, animated: true, completion: nil)
        
    }
    // MARK: - OTHER
    private func proceedToHotspotManualPage(deviceDocNum: String, devicename: String, serialNumber: String, password: String, ssid: String) {
        // Store data temporarily (or pass via sender)
        self.deviceDocNum = deviceDocNum
        self.deviceName = devicename
        self.serialNumber = serialNumber
        self.passwordInfo = password
        self.ssidInfo = ssid
        
        performSegue(withIdentifier: "gotohotspotManualconfirmation", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "gotohotspotManualconfirmation",
           let destManualVC = segue.destination as? PiCamSetupHotspotManual {
            destManualVC.deviceDocNum = deviceDocNum
            destManualVC.deviceName = deviceName
            destManualVC.serialNumber = serialNumber
            destManualVC.ssidInfo = ssidInfo
            destManualVC.passwordInfo = passwordInfo
        }
    }
}
