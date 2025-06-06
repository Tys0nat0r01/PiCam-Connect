//
//  FeedbackViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 17/2/2025.
//
import UIKit
import MessageUI

class FeedbackViewController: UIViewController {
    // UI Components
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var feedbackView: UIView! // Renamed to lowercase
    
    // Constants
    private let placeholderText = "Enter your feedback here..."
    private let placeholderColor = UIColor.lightGray
    private let recipientEmail = "milescomedia@icloud.com"
    private let defaultSubject = "PiCam Connect Feedback"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        feedbackView.isHidden = false
    }

    private func setupTextFields() {
        // Title TextField setup
        titleTextField.delegate = self
        
        // Description TextView setup
        descriptionTextView.text = placeholderText
        descriptionTextView.textColor = placeholderColor
        descriptionTextView.delegate = self
        descriptionTextView.layer.cornerRadius = 8 // Example improvement
    }

    @IBAction private func sendFeedbackTapped(_ sender: UIButton) {
        sendEmailFeedback()
    }
}

// MARK: - Email Handling
extension FeedbackViewController: MFMailComposeViewControllerDelegate {
    func sendEmailFeedback() {
        guard MFMailComposeViewController.canSendMail() else {
            showAlert(title: "Mail Not Available", message: "Please configure an email account to send feedback.")
            return
        }
        
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([recipientEmail])
        mailComposeVC.setSubject(titleTextField.text?.isEmpty ?? true ? defaultSubject : titleTextField.text!)
        
        let messageBody = (descriptionTextView.textColor == placeholderColor ? "" : descriptionTextView.text!)
        mailComposeVC.setMessageBody(messageBody, isHTML: false)
        
        present(mailComposeVC, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        switch result {
        case .sent:
            feedbackView.isHidden = true
            showAlert(title: "Thank You!", message: "Your feedback has been sent.")
        case .failed:
            if let error = error {
                showAlert(title: "Error", message: "Failed to send email: \(error.localizedDescription)")
            }
        default:
            break
        }
        controller.dismiss(animated: true)
    }
}

// MARK: - TextField/TextView Delegates
extension FeedbackViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeholderColor {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = placeholderColor
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

// MARK: - Alert Helper
extension FeedbackViewController {
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
