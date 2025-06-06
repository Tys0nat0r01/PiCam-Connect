//
//  PiCamOnboardingHeadsUp.swift
//  PiCam
//
//  Created by Tyson Miles on 29/4/2025.
//
import UIKit

class PiCamOnboardingHeadsUp: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomButton: UIButton!
    
    @IBAction func didTapBottomButton(_ sender: Any) {
        // Present next VC after current dismiss completes
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace with your storyboard name
            if let destVC = storyboard.instantiateViewController(withIdentifier: "WelcomePCMVC") as? UIViewController {
                destVC.modalPresentationStyle = .fullScreen
                self.present(destVC, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        configureInitialButtonState()
    }
    
    private func configureInitialButtonState() {
        bottomButton.alpha = 0.4
        bottomButton.isEnabled = false
    }
}

extension PiCamOnboardingHeadsUp: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollHeight = scrollView.frame.size.height
        let adjustedContentInset = scrollView.adjustedContentInset
        
        // Calculate bottom threshold with proper insets
        let bottomThreshold = contentHeight + adjustedContentInset.bottom - scrollHeight
        
        let isAtBottom = offsetY >= (bottomThreshold - 1) // Allow 1pt tolerance
        
        UIView.animate(withDuration: 0.3) {
            self.bottomButton.alpha = isAtBottom ? 1.0 : 0.4
            self.bottomButton.isEnabled = isAtBottom
        }
    }
}
