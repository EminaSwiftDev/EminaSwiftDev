//
//  YeastType.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import Foundation

enum YeastType: String, Codable, CaseIterable {
    case bread = "Bread Yeast"
    case wine = "Wine Yeast"
    case wild = "Wild Fermentation"
    case kefir = "Kefir Grains"
    case custom = "Custom"
    
    var displayName: String {
        return rawValue
    }
    
    // Base fermentation speed multiplier (1.0 = normal speed)
    var speedMultiplier: Double {
        switch self {
        case .bread:
            return 1.2 // Faster
        case .wine:
            return 0.9 // Slower
        case .wild:
            return 0.7 // Much slower
        case .kefir:
            return 1.0 // Normal
        case .custom:
            return 1.0 // Normal
        }
    }
}

