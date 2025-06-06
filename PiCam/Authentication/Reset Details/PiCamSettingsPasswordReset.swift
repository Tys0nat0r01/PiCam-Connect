//
//  PiCamSettingsPasswordReset.swift
//  PiCam
//
//  Created by Tyson Miles on 12/5/2025.
//
import UIKit
import FirebaseAuth

class ResetPasswordFromSettings: UITableViewController {
    let spinner = UIActivityIndicatorView(style: .medium)
    private let authManager = AuthManager.shared
    
    @IBOutlet var resetPWButton: UIButton!
    var currentUserEmail: String? {
        return Auth.auth().currentUser?.email
    }
    @IBAction func resetPasswordTapped(_ sender: Any) {
        authManager.sendResetPasswordEmail(email: currentUserEmail!)
        showErrorAlert(message: "Sending...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            guard let self = self else { return }
            showErrorAlert(message: "Sent!")
        }
        
    }
    
    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
}
