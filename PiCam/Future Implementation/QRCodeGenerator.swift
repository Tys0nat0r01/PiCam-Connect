//
//  Untitled.swift
//  PiCam
//
//  Created by Tyson Miles on 14/3/2025.
//

import UIKit

extension String {
    func generateQRCode() -> UIImage? {
        guard let data = self.data(using: String.Encoding.ascii) else { return nil }
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
        
        return UIImage(ciImage: output)
    }
}
