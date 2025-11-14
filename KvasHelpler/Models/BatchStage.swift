//
//  BatchStage.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import Foundation

enum BatchStage: String, Codable, CaseIterable {
    case primary = "Primary"
    case secondary = "Secondary"
    case coldCrash = "Cold Crash"
    case conditioning = "Conditioning"
    case bottled = "Bottled"
    
    var displayName: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .primary:
            return "flame.fill"
        case .secondary:
            return "drop.fill"
        case .coldCrash:
            return "snowflake"
        case .conditioning:
            return "timer"
        case .bottled:
            return "checkmark.circle.fill"
        }
    }
}

