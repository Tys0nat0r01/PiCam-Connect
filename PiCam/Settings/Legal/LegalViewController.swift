//
//  ViewController 2.swift
//  PiCam
//
//  Created by Tyson Miles on 13/4/2025.
//


import UIKit
import WebKit

class LegalViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let alert = MidAlertView(
            type: .loadingcustom,
            title: "",
            message: "",
            symbol: UIImage(named: "loadingspinner")
        )
        alert.show(in: view, duration: 5)
        // Replace with your website URL
        let url = URL(string: "https://picamlegal.my.canva.site/")!
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
