//
//  PiCam
//
//  Created by Tyson Miles on 19/3/2025.
//


import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class PasswordResetViewController: UIViewController, UITextFieldDelegate {
    var email: String?
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        self.emailTextField.delegate = self

        emailTextField.layer.cornerRadius = 22
        
        }
    
    private let authManager = AuthManager.shared
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendEmailTapped(_ sender: UIButton) {
        if emailTextField.hasText == true && emailTextField.text?.contains("@") == true {
            guard let email = emailTextField.text else {
                showErrorAlert(message: "Please enter an email")
                return
            }
            let alert = MidAlertView(
                type: .loadingcustom,
                title: "",
                message: "",
                symbol: UIImage(named: "loadingspinner")
            )
            alert.show(in: view, duration: 1)
            authManager.sendResetPasswordEmail(email: email)
            proceedToReset(email: email)
        }
        else {
            showErrorAlert(message: "Enter a Valid Email")
        }
    }
    
    private func proceedToReset(email: String) {
        // Store data temporarily (or pass via sender)
        self.email = email
        performSegue(withIdentifier: "showPasswordReset", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showPasswordReset",
           let destVC = segue.destination as? PasswordResetViewControllerEnd {
            destVC.email = self.email
        }
    }
    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
}
