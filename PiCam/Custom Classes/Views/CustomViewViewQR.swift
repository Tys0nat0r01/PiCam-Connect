//
//  CustomViewView 2.swift
//  PiCam
//
//  Created by Tyson Miles on 10/4/2025.
//


import UIKit

@IBDesignable
class CustomViewViewQR: UIView {
    // MARK: - Corner Radius Properties
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            if !screenCornersRadius {  // Only update if not using screen radius
                layer.cornerRadius = cornerRadius
                blurView?.layer.cornerRadius = cornerRadius
            }
            layer.masksToBounds = false
        }
    }
    
    @IBInspectable var screenCornersRadius: Bool = false {
        didSet {
            setNeedsLayout()  // Trigger layout update
        }
    }
    
    // MARK: - Shadow Properties
    @IBInspectable var shadowColor: UIColor = .clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    // MARK: - Blur Effect
    @IBInspectable var blurEnabled: Bool = false {
        didSet {
            blurEnabled ? addBlurEffect() : removeBlurEffect()
        }
    }
    
    private var blurView: UIVisualEffectView?
    
    private func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView?.frame = bounds
        blurView?.layer.cornerRadius = layer.cornerRadius  // Match current radius
        blurView?.clipsToBounds = true
        blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(blurView!, at: 0)
    }
    
    private func removeBlurEffect() {
        blurView?.removeFromSuperview()
        blurView = nil
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update corner radius based on device type
        if screenCornersRadius {
            let hasRoundedCorners = (window?.safeAreaInsets.top ?? 0) > 20  // Notch check
            layer.cornerRadius = hasRoundedCorners ? 44 : 0
            blurView?.layer.cornerRadius = layer.cornerRadius
        }
        
        // Shadow path
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: layer.cornerRadius
        ).cgPath
    }
}
