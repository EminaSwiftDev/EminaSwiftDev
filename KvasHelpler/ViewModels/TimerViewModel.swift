//
//  TimerViewModel.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import Foundation
import SwiftUI

@Observable
class TimerViewModel {
    var temperature: Double = 22.0
    var initialSweetness: Double = 12.0
    var yeastType: YeastType = .bread
    var yeastAmount: Double = 5.0
    var volume: Double = 5.0
    var desiredSweetness: TimerParameters.SweetnessLevel = .medium
    var desiredCarbonation: TimerParameters.CarbonationLevel = .medium
    var desiredAcidity: TimerParameters.AcidityLevel = .soft
    
    var calculatedTime: TimeInterval {
        let parameters = TimerParameters(
            temperature: temperature,
            initialSweetness: initialSweetness,
            yeastType: yeastType,
            yeastAmount: yeastAmount,
            volume: volume,
            desiredSweetness: desiredSweetness,
            desiredCarbonation: desiredCarbonation,
            desiredAcidity: desiredAcidity
        )
        return FermentationCalculator.calculateFermentationTime(parameters: parameters)
    }
    
    var calculatedDays: Int {
        Int(ceil(calculatedTime))
    }
    
    func createParameters() -> TimerParameters {
        TimerParameters(
            temperature: temperature,
            initialSweetness: initialSweetness,
            yeastType: yeastType,
            yeastAmount: yeastAmount,
            volume: volume,
            desiredSweetness: desiredSweetness,
            desiredCarbonation: desiredCarbonation,
            desiredAcidity: desiredAcidity
        )
    }
    
    func reset() {
        temperature = 22.0
        initialSweetness = 12.0
        yeastType = .bread
        yeastAmount = 5.0
        volume = 5.0
        desiredSweetness = .medium
        desiredCarbonation = .medium
        desiredAcidity = .soft
    }
}

