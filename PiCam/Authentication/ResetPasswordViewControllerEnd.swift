//
// 
//  PiCam
//
//  Created by Tyson Miles on 19/3/2025.
//


import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class PasswordResetViewControllerEnd: UIViewController {
    var email: String?
    @IBOutlet weak var emailText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailText.text = email
        }
    
    private let authManager = AuthManager.shared
    
    @IBAction func resendPressed(_ sender: Any) {
        authManager.sendResetPasswordEmail(email: email!)
        showErrorAlert(message: "Password Reset Email Sent")
    }
    
    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
}
