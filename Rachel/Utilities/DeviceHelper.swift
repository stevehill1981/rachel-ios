//
//  DeviceHelper.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import UIKit

struct DeviceHelper {
    static func getPlayerName() -> String {
        let deviceName = UIDevice.current.name
        
        // Try to extract first name from device name
        // Common patterns: "Steve's iPhone", "iPhone de Marie", etc.
        
        // Pattern 1: "Name's Device"
        if let apostropheIndex = deviceName.firstIndex(of: "'") {
            let name = String(deviceName.prefix(upTo: apostropheIndex))
            if !name.isEmpty && name != "iPhone" && name != "iPad" {
                return name
            }
        }
        
        // Pattern 2: "Device de Name"
        if deviceName.contains(" de ") {
            let components = deviceName.components(separatedBy: " de ")
            if components.count > 1 {
                let name = components[1]
                if !name.isEmpty {
                    return name
                }
            }
        }
        
        // Default fallback
        return "You"
    }
}