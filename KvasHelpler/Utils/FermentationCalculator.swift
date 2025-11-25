//
//  FermentationCalculator.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import Foundation

struct FermentationCalculator {
    
    /// Calculate fermentation time in days based on parameters
    static func calculateFermentationTime(parameters: TimerParameters) -> TimeInterval {
        var baseDays: Double = 7.0 // Base fermentation time
        
        // Temperature factor (optimal around 20-25°C)
        let optimalTemp: Double = 22.0
        let tempDiff = abs(parameters.temperature - optimalTemp)
        let tempFactor: Double
        if parameters.temperature < 15 {
            tempFactor = 1.5 + (15 - parameters.temperature) * 0.1 // Much slower when cold
        } else if parameters.temperature > 30 {
            tempFactor = 0.7 - (parameters.temperature - 30) * 0.05 // Faster when hot, but not too much
        } else {
            tempFactor = 1.0 - (tempDiff / optimalTemp) * 0.3 // Normal range
        }
        
        // Initial sweetness factor (more sugar = more time)
        let sweetnessFactor = 1.0 + (parameters.initialSweetness / 20.0) * 0.5
        
        // Yeast type factor
        let yeastFactor = 1.0 / parameters.yeastType.speedMultiplier
        
        // Yeast amount factor (more yeast = faster)
        let yeastAmountFactor = 1.0 / (1.0 + parameters.yeastAmount / 10.0)
        
        // Volume factor (larger volume might need slightly more time)
        let volumeFactor = 1.0 + (parameters.volume / 50.0) * 0.1
        
        // Desired result factors
        var resultFactor: Double = 1.0
        
        // Sweetness: dry needs more time, sweet needs less
        switch parameters.desiredSweetness {
        case .sweet:
            resultFactor *= 0.8
        case .medium:
            resultFactor *= 1.0
        case .dry:
            resultFactor *= 1.3
        case .targetBrix:
            resultFactor *= 1.1
        }
        
        // Carbonation: high needs more time for conditioning
        switch parameters.desiredCarbonation {
        case .low:
            resultFactor *= 0.9
        case .medium:
            resultFactor *= 1.0
        case .high:
            resultFactor *= 1.1
        }
        
        // Calculate final time
        let totalDays = baseDays * tempFactor * sweetnessFactor * yeastFactor * yeastAmountFactor * volumeFactor * resultFactor
        
        // Clamp between 3 and 30 days
        return max(3.0, min(30.0, totalDays))
    }
    
    /// Calculate estimated completion date
    static func calculateCompletionDate(startDate: Date, parameters: TimerParameters) -> Date {
        let days = calculateFermentationTime(parameters: parameters)
        return Calendar.current.date(byAdding: .day, value: Int(days), to: startDate) ?? startDate
    }
}

