//
//  PiCamSettingsPasswordReset.swift
//  PiCam
//
//  Created by Tyson Miles on 12/5/2025.
//
import UIKit
import FirebaseAuth

class AccountSecurityPage: UITableViewController {
    
    private let authManager = AuthManager.shared
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    var currentUserUID: String? {
        return Auth.auth().currentUser?.uid
    }
    var currentUserEmail: String? {
        return Auth.auth().currentUser?.email
    }
    var userSince: String? {
        return Auth.auth().currentUser?.metadata.creationDate?.description
    }
    var lastSignIn: String? {
        return Auth.auth().currentUser?.metadata.lastSignInDate?.description
    }
    var verifiedEmail: String? {
        return Auth.auth().currentUser!.isEmailVerified ? "Verified" : "Not verified"
    }
    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var useridLabel: UILabel!
    @IBOutlet var lastSignInLabel: UILabel!
    @IBOutlet var verifiedEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailLabel.text = currentUserEmail ?? "No user logged in"
        verifiedEmailLabel.text = verifiedEmail ?? " "
        lastSignInLabel.text = lastSignIn ?? " "
        useridLabel.text = currentUserUID ?? "No user logged in"
    }
    
    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
}
