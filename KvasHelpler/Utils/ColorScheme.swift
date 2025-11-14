//
//  ColorScheme.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI

extension Color {
    static func colorForStage(_ stage: BatchStage) -> Color {
        switch stage {
        case .primary:
            return Color.orange
        case .secondary:
            return Color.blue.opacity(0.7)
        case .coldCrash:
            return Color.cyan
        case .conditioning:
            return Color.purple.opacity(0.7)
        case .bottled:
            return Color.green
        }
    }
    
    static func backgroundColorForStage(_ stage: BatchStage) -> Color {
        switch stage {
        case .primary:
            return Color.orange.opacity(0.15)
        case .secondary:
            return Color.blue.opacity(0.1)
        case .coldCrash:
            return Color.cyan.opacity(0.15)
        case .conditioning:
            return Color.purple.opacity(0.1)
        case .bottled:
            return Color.green.opacity(0.15)
        }
    }
}

