//
//  AccountPage.swift
//  PiCam
//
//  Created by Tyson Miles on 23/3/2025.
//
import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Darwin
class AccountPage: UITableViewController {
    
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
    @IBOutlet var userSinceLabel: UILabel!
    @IBOutlet var verifiedEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailLabel.text = currentUserEmail ?? "No user logged in"
        verifiedEmailLabel.text = verifiedEmail ?? " "
       // userSinceLabel.text = userSince ?? " "
        useridLabel.text = currentUserUID ?? "No user logged in"
    }
    @IBAction func logoutTapped(_ sender: Any) {
        try! Auth.auth().signOut()
        showErrorAlert(message: "Signing out...")
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        Core.shared.setIsNewUser()
        sleep(2)
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "WelcomePCMVC")
        controller?.modalPresentationStyle = .fullScreen
        controller?.modalTransitionStyle = .crossDissolve
        present(controller!, animated: true, completion: nil)
        
    }
    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
}
