//
//  SettingsTableViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 30/3/2025.
//
import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {
    private  let spinner = UIActivityIndicatorView(style: .medium)
    
    // MARK: - UITableViewDelegate
    
    @IBAction func signOutTapped(_ sender: UIButton) {
        showSignOutAlert( )
    }
    @IBAction func vehiclesInfoTapped(_ sender:  UIButton) {
        let alert = MidAlertView(
            type: .alert,
            title: "Feature Not Available Yet",
            message: "'Vehicles' is currently not available yet. This feature is still in development and should be available in a future update.",
            symbol: UIImage(systemName: "square.and.arrow.down.badge.clock.fill"),
            primaryAction: {},
            primaryActionName: "OK",
            primaryActionColor: .systemBlue
        )
        
        alert.show(in: view)
    }
    
    private func showSignOutAlert() {
        let alertController = UIAlertController(title: "Log Out", message: "Are you sure you want to log out of your PiCam Connect account?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { [self] _ in
            do {
                try Auth.auth().signOut()
                showErrorAlert(message: "Signing you out...")
                spinner.center = view.center
                view.addSubview(spinner)
                spinner.startAnimating()
                Core.shared.setIsNewUser()
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "WelcomePCMVC")
                controller?.modalPresentationStyle = .fullScreen
                controller?.modalTransitionStyle = .crossDissolve
                self.present(controller!, animated: true, completion: nil)
                
            } catch let signOutError as NSError {
                self.showErrorAlert(message: signOutError.localizedDescription)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
}
