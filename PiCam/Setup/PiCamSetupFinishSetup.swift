//
//  PiCamSetupFinishSetup.swift
//  PiCam
//
//  Created by Tyson Miles on 25/4/2025.
//
import UIKit

class PiCamSetupFinishSetup: UIViewController {
    @IBOutlet weak var SuccessImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SuccessImage.image = UIImage(systemName: "checkmark.circle.fill")
        SuccessImage.addSymbolEffect(.bounce.down.byLayer, options: .repeat(.periodic(delay: 2.0)))
    }
    
    
}
