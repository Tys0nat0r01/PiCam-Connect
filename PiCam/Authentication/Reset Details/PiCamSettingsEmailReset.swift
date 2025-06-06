//
//  PiCamSettingsPasswordReset.swift
//  PiCam
//
//  Created by Tyson Miles on 12/5/2025.
//
import UIKit
import FirebaseAuth

class ResetEmailFromSettings: UITableViewController, AuthenticationDelegate {
    
    let spinner = UIActivityIndicatorView(style: .medium)
    private let authManager = AuthManager.shared

    @IBOutlet var resetEmailField: UITextField!
    @IBOutlet var notificationView: UIView!
    @IBOutlet var currentEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentEmailLabel.text = currentUserEmail
        notificationView.isHidden = true
    }
    
    var currentUserEmail: String? {
        return Auth.auth().currentUser?.email
    }
    //MARK: - AUTHENTICATION
    
    func authenticationDidComplete(success: Bool) {
        if success {
            // Proceed with email reset after successful authentication
            print("Successfully authenticated")
            self.performEmailReset()
        } else {
            // Handle authentication cancellation
            let alert = MidAlertView(
                type: .alert,
                title: "An Error Occured",
                message: "Authentication was cancelled. Try again later. ",
                symbol: UIImage(systemName: "questionmark.text.page.fill"),
                primaryAction: { print("insert action") },
                secondaryActionName: "Learn More",
                primaryActionName: "OK",
                primaryActionColor: .systemBlue,
                secondaryActionColor: .systemGray,
                secondaryAction: { print("insert action")},
            )
            
            alert.show(in: self.view)
        }
    }
    
    private func performEmailReset() {
        guard let newEmail = resetEmailField.text else {
            showErrorAlert(message: "Please enter a valid email address")
            return
        }

        let alert = MidAlertView(
            type: .loadingcustom,
            title: "Updating Email...",
            message: "",
            symbol: UIImage(named: "loadingspinner")
        )
        alert.show(in: view)
        
        Auth.auth().currentUser?.__sendEmailVerificationBeforeUpdating(email: newEmail) { [weak self] error in
            DispatchQueue.main.async {
                alert.dismiss()
                
                if let error = error {
                    let alert = MidAlertView(
                        type: .alert,
                        title: "An Error Occured",
                        message: "An error occured while sending the verification link to update your email. The error was \(error.localizedDescription). ",
                        symbol: UIImage(systemName: "questionmark.text.page.fill"),
                        primaryAction: { print("insert action") },
                        secondaryActionName: "Learn More",
                        primaryActionName: "OK",
                        primaryActionColor: .systemBlue,
                        secondaryActionColor: .systemGray,
                        secondaryAction: { print("insert action")},
                    )
                    
                    alert.show(in: self!.view)
                } else {
                    self?.notificationView.isHidden = false
                    self?.showErrorAlert(message: "Success! Email Sent")
                }
            }
        }
    }

    //MARK: - RESET EMAIL
    @IBAction func resetEmailButtonTapped(_ sender: UIButton) {
        performEmailReset()
    }
    
    func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
    
}
