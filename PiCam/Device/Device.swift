//
//  Device.swift
//  PiCam
//
//  Created by Tyson Miles on 14/3/2025.
//
import Foundation

struct Device: Codable {
    let useruid: String
    let serialnum: String
    let devicename: String
    let modelnum: String
    let videohours: Int
    let activated: Bool
    let lastseen: Date
    let friendlyname: String
    let wifipassword: String
    let wifissid: String
    let status: String
}
