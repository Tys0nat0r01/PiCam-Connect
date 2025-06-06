//
//  DeviceCell.swift
//  PiCam
//
//  Created by Tyson Miles on 20/3/2025.
//
import UIKit

class DeviceCell: UITableViewCell {
    static let reuseIdentifier = "DeviceCell"
    
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    
    func configure(with device: Device) {
        serialLabel.text = "\(device.serialnum)"
        nameLabel.text = device.devicename
        modelLabel.text = "\(device.modelnum)"
    }
}
