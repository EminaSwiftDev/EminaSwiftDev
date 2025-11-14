//
//  FavoriteRecipe.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import Foundation
import SwiftData

@Model
final class FavoriteRecipe {
    var id: UUID
    var name: String
    var timerParametersData: Data? // Encoded TimerParameters
    var volume: Double
    var equipment: String
    var initialTemperature: Double?
    var createdAt: Date
    
    var timerParameters: TimerParameters? {
        get {
            guard let data = timerParametersData else { return nil }
            return try? JSONDecoder().decode(TimerParameters.self, from: data)
        }
        set {
            timerParametersData = try? JSONEncoder().encode(newValue)
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        timerParameters: TimerParameters? = nil,
        volume: Double = 5.0,
        equipment: String = "",
        initialTemperature: Double? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.volume = volume
        self.equipment = equipment
        self.initialTemperature = initialTemperature
        self.createdAt = createdAt
        // Set timerParametersData directly to avoid initialization order issues
        if let parameters = timerParameters {
            self.timerParametersData = try? JSONEncoder().encode(parameters)
        } else {
            self.timerParametersData = nil
        }
    }
}

