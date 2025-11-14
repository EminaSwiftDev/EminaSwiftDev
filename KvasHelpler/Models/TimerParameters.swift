//
//  TimerParameters.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import Foundation

struct TimerParameters: Codable {
    var temperature: Double // °C
    var initialSweetness: Double // °Bx or g/L sugar
    var yeastType: YeastType
    var yeastAmount: Double // grams or % of volume
    var volume: Double // liters
    var desiredSweetness: SweetnessLevel
    var desiredCarbonation: CarbonationLevel
    var desiredAcidity: AcidityLevel
    
    enum SweetnessLevel: String, Codable, CaseIterable {
        case sweet = "Sweet"
        case medium = "Medium"
        case dry = "Dry"
        case targetBrix = "Target °Bx"
    }
    
    enum CarbonationLevel: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
    
    enum AcidityLevel: String, Codable, CaseIterable {
        case soft = "Soft"
        case slightlyAcidic = "Slightly Acidic"
        case targetPH = "Target pH"
    }
}

