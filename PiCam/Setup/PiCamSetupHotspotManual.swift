//
//  PiCamSetupHotspotManual.swift
//  PiCam
//
//  Created by Tyson Miles on 26/4/2025.
//
import Foundation
import UIKit
import SystemConfiguration.CaptiveNetwork


class PiCamSetupHotspotManual: UIViewController {
    var ssidInfo: String?
    var passwordInfo: String?
    var deviceName: String?
    var serialNumber: String?
    var deviceDocNum: String?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    let hotspotManager = HotspotManager()
    @IBOutlet weak var ssidLabel: UILabel!
    override func viewDidLoad() {
    
        super.viewDidLoad()
        ssidLabel.text = "Connect to: \(ssidInfo ?? "No Device Found")"
        }
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        cancelSetup()
    }
    @IBAction func connectButtonTapped(_ sender: Any) {
        let alert = MidAlertView(
            type: .loadingcustom,
            title: nil,
            message: nil,
            symbol: UIImage(named: "loadingspinner")
        )
        alert.show(in: view, duration: 2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let deviceName = self!.deviceName else {
                // Handle deviceName being nil if needed
                return
            }
            guard let currentSSID = self!.getCurrentSSID(), currentSSID == deviceName else {
                let erroralert = MidAlertView(
                    type: .alert,
                    title: "Unable to Connect",
                    message: "An error occured while connecting to your PiCam, please try again or view our docs for more info by pressing 'Help' below.",
                    symbol: UIImage(systemName: "wifi.exclamationmark.circle.fill"),
                    primaryAction: { print("insert action") },
                    secondaryActionName: "Help",
                    primaryActionName: "OK",
                    primaryActionColor: .systemBlue,
                    secondaryActionColor: .systemGray,
                    secondaryAction: { print("insert action")},
                )
                
                erroralert.show(in: self!.view)
                return
            }
            
            guard let self = self,
                  let serialNumber = self.serialNumber,
                  let deviceDocNum = self.deviceDocNum else { return }
            
            self.proceedToConfirmationPage(
                devicename: deviceName,
                serialNumber: serialNumber,
                deviceDocNum: deviceDocNum
            )
        }
    }
    func getCurrentSSID() -> String? {
        var ssid: String?
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return nil }
        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] else { continue }
            ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
            break
        }
        return ssid
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
    
}
