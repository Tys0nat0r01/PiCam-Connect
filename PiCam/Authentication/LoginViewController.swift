//
//  LoginViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 19/3/2025.
//


import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import AuthenticationServices
import Foundation

class LoginViewController: UIViewController, UITextFieldDelegate, AuthUIDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordSecButton: UIButton!
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self

        emailTextField.layer.cornerRadius = 22
        passwordTextField.layer.cornerRadius = 22
        
        }
    
    private let authManager = AuthManager.shared
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ShowTapped(_ sender: UIButton) {
        if passwordTextField.isSecureTextEntry == false {
            passwordTextField.isSecureTextEntry = true
            passwordSecButton.setImage(UIImage(systemName:"eye.slash.fill"), for: UIButton.State.normal)
            
        }
        else {
            passwordTextField.isSecureTextEntry = false
            passwordSecButton.setImage(UIImage(systemName:"eye.fill"), for: UIButton.State.normal)
        }
    }
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            showErrorAlert(message: "Please fill all fields")
            return
        }
        let alert = MidAlertView(
            type: .loadingcustom,
            title: "Signing In...",
            message: "",
            symbol: UIImage(named: "loadingspinner")
        )
        alert.show(in: view, duration: 1)
        authManager.signIn(email: email, password: password) { [weak self] result in
            switch result {
            case .success:
                // Present the SignedInViewController
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let signedInVC = storyboard.instantiateViewController(withIdentifier: "SignedInVC") as? SignedInViewController {
                        // Use the appropriate presentation style for your app
                        signedInVC.modalPresentationStyle = .fullScreen
                        self?.present(signedInVC, animated: true, completion: nil)
                        
                        // Alternatively, if you're using a navigation controller:
                        // self?.navigationController?.pushViewController(signedInVC, animated: true)
                    }
                }
                
            case .failure(let error):
                if (error.localizedDescription == "The supplied auth credential is malformed or has expired.") {
                    self?.showErrorAlert(message: "Invalid Credentials")
                }
                if (error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred.") {
                    self?.showErrorAlert(message: "Network Error. Please try again.")
                }
                if (error.localizedDescription == "The email address is badly formatted.") {
                    self?.showErrorAlert(message: "Email address is invalid")
                }
                if (error.localizedDescription == "Error") {
                    self?.showErrorAlert(message: "An Error Occured")
                }
            }
        }
    }
    func signInWithGitHub() {
        let clientID = "Ov23lis5VDNzyEtm96VM"
        let redirectURI = "com.milescomedia.PiCam://auth/github" // e.g., com.example.app://auth/github
        let scopes = "user:email" // Request email access
        
        let authURL = "https://github.com/login/oauth/authorize?client_id=\(clientID)&redirect_uri=\(redirectURI)&scope=\(scopes)"
        
        guard let url = URL(string: authURL) else { return }
        
        // Start the authentication session
        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "com.milescomedia.PiCam" // Must match your app's URL scheme
        ) { callbackURL, error in
            if let error = error {
                print("GitHub auth error: \(error)")
                return
            }
            guard let callbackURL = callbackURL else { return }
        }
        
        // Present the session
        session.presentationContextProvider = self
        session.start()
    }
    
    
    //Change url.scheme with your app name that you set in GitHub developer settings
    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
}
extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
