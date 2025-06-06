//
//  LoginViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 19/3/2025.
//


import UIKit

class SignupPassViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var displayEmailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordSecButton: UIButton!
    
    var text: String?
    var isNEWSIGNEDINUser: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordTextField.delegate = self

        if text != nil {
            displayEmailTextField.text = text
            
        }
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
    @IBAction func signUpTapped(_ sender: UIButton) {
        guard let email = displayEmailTextField.text,
              let password = passwordTextField.text else {
            showErrorAlert(message: "Please fill all fields")
            return
        }
        if ((passwordTextField.text?.contains(" ")) != false) {
            showErrorAlert(message: "Password cannot contain spaces")
        }
        else {
            authManager.signUp(email: email, password: password) { [weak self] result in
                switch result {
                case .success:
                    let controller = self?.storyboard?.instantiateViewController(withIdentifier: "OnboardVC") as! WelcomeViewController
                    controller.modalPresentationStyle = .fullScreen
                    controller.modalTransitionStyle = .crossDissolve
                    self?.present(controller, animated: true, completion: nil)
                case .failure(let error):
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
    
}
