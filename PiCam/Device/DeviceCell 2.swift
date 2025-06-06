//
//  DeviceCell 2.swift
//  PiCam
//
//  Created by Tyson Miles on 29/3/2025.
//


import UIKit

class DeviceCell2: UITableViewCell {
    static let reuseIdentifier = "DeviceCell2"
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusimage: UIImageView!
    
    func configure(with device: Device) {
        nameLabel.text = device.devicename
        statusLabel.text = device.status
        if device.status == "Recording" {
            statusimage.removeAllSymbolEffects()
            statusimage.image = UIImage(systemName: "record.circle.fill")
            statusimage.tintColor = .systemRed
            statusimage.addSymbolEffect(.breathe.pulse.byLayer, options: .repeat(.continuous))
        }
        if device.status == "Idle" {
            statusimage.removeAllSymbolEffects()
            statusimage.image = UIImage(systemName: "clock.circle.fill")
            statusimage.tintColor = .secondaryLabel
            statusimage.addSymbolEffect(.breathe.pulse.byLayer, options: .repeat(.continuous))
        }
        if device.status == "Unknown" {
            statusimage.removeAllSymbolEffects()
            statusimage.image = UIImage(systemName: "questionmark.circle.fill")
            statusimage.tintColor = .secondaryLabel
            statusimage.addSymbolEffect(.breathe.pulse.byLayer, options: .repeat(.continuous))
        }
        if device.status == "Not Recording" {
            statusimage.removeAllSymbolEffects()
            statusimage.image = UIImage(systemName: "exclamationmark.triangle.fill")
            statusimage.tintColor = .systemYellow
            statusimage.addSymbolEffect(.breathe.pulse.byLayer, options: .repeat(.continuous))
        }
        if device.status == "Updating" {
            statusimage.removeAllSymbolEffects()
            statusimage.image = UIImage(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
            statusimage.tintColor = .secondaryLabel
            statusimage.addSymbolEffect(.rotate.byLayer, options: .repeat(.continuous))
        }
    }
}
