//
//  SignedInViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 25/3/2025.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore
import Darwin
import Photos
import UserNotifications
import CoreLocation
import Network

class SignedInViewController: UIViewController {
    private let spinner = UIActivityIndicatorView(style: .large)
    @IBOutlet weak var UsernameLabel: UILabel!
    var isNEWSIGNEDINUser: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        requestPermissions()
    }
    func updateUI() {
        if let user = Auth.auth().currentUser {
            UsernameLabel.text = user.email
            showErrorAlert(message: "Signed In")
        }
    }
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        Core.shared.setIsNotNewUser()
        
    }
    @IBAction func SignOutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            updateUI()
            showErrorAlert(message: "Signing Out")
            spinner.center = view.center
            view.addSubview(spinner)
            sleep(2)
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "WelcomePCMVC")
            controller?.modalPresentationStyle = .fullScreen
            present(controller!, animated: false, completion: nil)
            
        } catch {
            showErrorAlert(message: error.localizedDescription)
        }
    }
    
    func requestPermissions() {
        // Request Location Permissions
        // Request Photo Library Additions Usage Permissions
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized, .limited:
                print("Photo Library access granted")
            case .denied, .restricted, .notDetermined:
                print("Photo Library access denied")
            @unknown default:
                fatalError()
            }
        }

        // Request Notifications Permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications access granted")
            } else {
                print("Notifications access denied")
            }
        }
    }
    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
        
    }
}
