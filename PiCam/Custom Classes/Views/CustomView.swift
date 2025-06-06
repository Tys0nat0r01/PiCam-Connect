//
//  CustomView.swift
//  PiCam
//
//  Created by Tyson Miles on 22/3/2025.
//
import UIKit

@IBDesignable
class CustomView: UIStackView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}
