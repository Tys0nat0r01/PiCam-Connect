//
//  ConfirmationViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 3/4/2025.
//
import AVFoundation
import Network
import FirebaseFirestore
import UIKit

class ConfirmationViewController: UIViewController {
    var ssidInfo: [String]?
    var serialnumber: String?
    var hotspotManager: HotspotManager?
    var piConnection: NWConnection?
    let piAddress = "192.168.4.1"
    let piPort: NWEndpoint.Port = 4545
    
    @IBOutlet weak var ssidLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ssidLabel.text = "Connect to \(ssidInfo?[0] ?? "unknown")?"
        serialLabel.text = "Connect to \(serialnumber ?? "unknown")?"
    }
    
    @IBAction func confirmConnection(_ sender: UIButton) {
        guard let ssid = ssidInfo?[0], let password = ssidInfo?[1] else { return }
        hotspotManager?.connectToHotspot(ssid: ssid, password: password) { success in
            if success {
                self.connectToPiServer()
            }
        }
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
            default: break
            }
        }
        
        piConnection?.start(queue: .main)
    }
    
    func sendSerialRequest() {
        let message = "sendserialnumber"
        piConnection?.send(content: message.data(using: .utf8), completion: .contentProcessed { error in
            if let error = error {
                print("Send error: \(error)")
                return
            }
            self.receiveSerial()
        })
    }
    
    func receiveSerial() {
        piConnection?.receive(minimumIncompleteLength: 1, maximumLength: 100) { [weak self] data, _, isComplete, error in
            guard let data = data, let serial = String(data: data, encoding: .utf8) else { return }
            
            self?.verifySerialWithFirebase(serial: serial)
            if isComplete {
                self?.piConnection?.cancel()
            }
        }
    }
    
    func verifySerialWithFirebase(serial: String) {
        let db = Firestore.firestore()
        db.collection("devices").whereField("serialnumber", isEqualTo: serial).getDocuments { snapshot, error in
            if let docs = snapshot?.documents, !docs.isEmpty {
                print("Valid serial number")
                // Proceed with setup
            } else {
                print("Invalid serial number")
                // Show error
            }
        }
    }
}

