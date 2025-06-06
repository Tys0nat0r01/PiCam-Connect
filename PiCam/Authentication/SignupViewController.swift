//
//  SignupViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 19/3/2025.
//


import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.emailTextField.delegate = self
        emailTextField.layer.cornerRadius = 22
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func alreadyAccPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        if (emailTextField.text?.isEmpty == false) && (emailTextField.text?.contains("@") == true) {
            let controller = storyboard?.instantiateViewController(withIdentifier: "SignupPASSVC") as! SignupPassViewController
            controller.text = emailTextField.text
            controller.modalPresentationStyle = .overCurrentContext
            controller.modalTransitionStyle = .coverVertical
            present(controller, animated: true, completion: nil)
        }
        else {
            showErrorAlert(message: "Enter a valid Email to continue")
        }
    }
    func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
}

