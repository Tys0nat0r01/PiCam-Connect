//
//  PiCamSetupEnableHTSPT.swift
//  PiCam
//
//  Created by Tyson Miles on 12/4/2025.
//
import UIKit
import AVFoundation

class PiCamSetupEnableHTSPT: UIViewController {
    
    var audioPlayer: AVAudioPlayer?
    var ssid: String?
    var deviceName: String?
    var password: String?
    var serialNumber: String?
    var deviceDocNum: String?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("IN Hotspot page. SSID: \(ssid ?? "unknown")")
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        cancelSetup()
    }
    @IBAction func playSoundTapped(_ sender: UIButton) {
        let alert = MidAlertView(
            type: .loadingcustom,
            title: nil,  // Ignored
            message: "",  // Ignored
            symbol: UIImage(named: "loadingspinner")
        )
        alert.show(in: view, duration: 0)
            playSound(named: "notification_bell")
        }

    private func playSound(named filename: String) {
        guard let url = Bundle.main.url(
            forResource: filename,
            withExtension: "mp3"
        ) else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    @IBAction func chimeHeardTapped(_ sender: UIButton) {
        guard let ssid = ssid, let password = password, let deviceName = deviceName, let serialNumber = serialNumber else {
            print("Missing required information to proceed to confirmation.")
            return
        }

        let alert = MidAlertView(
            type: .loadingcustom,
            title: "",
            message: "",
            symbol: UIImage(named: "loadingspinner")
        )
        alert.show(in: view, duration: 0.9)
        proceedToConfirmationPage(ssid: ssid, password: password, devicename: deviceName, serialNumber: serialNumber)
    }

    @IBAction func chimeNotHeardTapped(_ sender: UIButton) {
        // Handle the case where the chime is not heard
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

    // In PiCamSetupViewController
    private func proceedToConfirmationPage(ssid: String, password: String, devicename: String, serialNumber: String) {
        // Store data temporarily (or pass via sender)
        self.password = password
        self.ssid = ssid
        self.deviceName = devicename
        self.serialNumber = serialNumber
        
        performSegue(withIdentifier: "gotohotspotconfirmation", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "gotohotspotconfirmation",
           let destVC = segue.destination as? PiCamSetupHotspot {
            destVC.ssidInfo = ssid
            destVC.deviceDocNum = deviceDocNum
            destVC.passwordInfo = password
            destVC.deviceName = deviceName
            destVC.serialNumber = serialNumber
        }
    }
}

