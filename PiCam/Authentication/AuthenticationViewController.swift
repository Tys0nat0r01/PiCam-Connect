//
// 
//  PiCam
//
//  Created by Tyson Miles on 19/3/2025.
//

import UIKit
import FirebaseAuth

protocol AuthenticationDelegate: AnyObject {
    func authenticationDidComplete(success: Bool)
}

class AuthenticationViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Storyboard Outlets
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordSecButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: - Properties
    weak var delegate: AuthenticationDelegate?
    private let authManager = AuthManager.shared
    
    var currentUserEmail: String? {
        return Auth.auth().currentUser?.email
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        passwordTextField.delegate = self
        passwordTextField.layer.cornerRadius = 22
        emailTextField.text = currentUserEmail
    }

    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Actions
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        passwordSecButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func cancelAuthentication(_ sender: UIButton) {
        showCancelConfirmation()
    }

    @IBAction func attemptReauthentication(_ sender: UIButton) {
        guard validateInput() else { return }
        showLoadingIndicator()
        performReauthentication()
    }

    // MARK: - Authentication Logic
    private func validateInput() -> Bool {
        guard let password = passwordTextField.text, !password.isEmpty else {
            showErrorAlert(message: "Please enter your password")
            return false
        }
        return true
    }

    private func performReauthentication() {
        guard let email = currentUserEmail,
              let password = passwordTextField.text else { return }

        authManager.reauthenticateWithEmail(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.handleAuthenticationSuccess()
                case .failure(let error):
                    self?.handleAuthenticationError(error)
                }
            }
        }
    }

    // MARK: - Result Handling
    private func handleAuthenticationSuccess() {
        delegate?.authenticationDidComplete(success: true)
        dismiss(animated: true) {
            self.showSuccessAlert()
        }
    }

    private func handleAuthenticationError(_ error: Error) {
        let errorMessage = ErrorHandler.message(for: error)
        showErrorAlert(message: errorMessage)
    }

    // MARK: - Alert Handling
    private func showCancelConfirmation() {
        let alert = MidAlertView(
            type: .alert,
            title: "Cancel Authentication?",
            message: "Are you sure you want to cancel? You'll need to authenticate again to perform this action.",
            symbol: UIImage(systemName: "exclamationmark.circle.fill"),
            primaryAction: { [weak self] in
                self?.delegate?.authenticationDidComplete(success: false)
                self?.dismiss(animated: true)
            },
            secondaryActionName: "Cancel Authentication",
            primaryActionName: "Nevermind",
            primaryActionColor: .systemGray,
            secondaryActionColor: .systemBlue
        )
        alert.show(in: view)
    }

    private func showLoadingIndicator() {
        let alert = MidAlertView(
            type: .loadingcustom,
            title: "Authenticating...",
            message: "",
            symbol: UIImage(named: "loadingspinner")
        )
        alert.show(in: view, duration: 1)
    }

    private func showSuccessAlert() {
        let alert = MidAlertView(
            type: .success,
            title: "Authentication Successful",
            message: "You may now continue your action",
            symbol: UIImage(systemName: "checkmark.circle.fill")
        )
        alert.show(in: view, duration: 1)
    }

    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
}

// MARK: - Error Handling Utility
struct ErrorHandler {
    static func message(for error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password"
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection"
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Too many attempts. Please try again later"
        default:
            return "Authentication failed. Please try again"
        }
    }
}
