//
//  PiCamSetupHelp.swift
//  PiCam
//
//  Created by Tyson Miles on 26/4/2025.
//

import UIKit

class PiCamSetupHelp: UIViewController {
    @IBOutlet weak var HelpImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        HelpImage.image = UIImage(systemName: "bubble.left.and.exclamationmark.bubble.right.fill")
        HelpImage.addSymbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 3.0)))
    }
    @IBAction func ViewDocstapped(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://github.com/Tys0nat0r01/PiCam-Connect/wiki")!)
    }
    @IBAction func ContactSupporttapped(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://github.com/tys0nat0r01/PiCam-Connect")!)
    }
    @IBAction func PostIssuetapped(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://github.com/Tys0nat0r01/PiCam-Connect/issues/new?template=ios-bug-report.yml ")!)
    }
}
