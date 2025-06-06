//
//  WelcomeViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 11/3/2025.
//
import UIKit

class WelcomeViewController: UIViewController {
    var isNEWSIGNEDINUser: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showErrorAlert(message: "Welcome to PiCam Connect")
        
    }
    @IBOutlet var dismissButton: UIButton!
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        Core.shared.setIsNotNewUser()
    
    }
    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
    
    
}

