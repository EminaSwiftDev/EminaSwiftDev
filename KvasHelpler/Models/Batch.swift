//
//  Batch.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import Foundation
import SwiftData

@Model
final class Batch {
    var id: UUID
    var name: String
    var volume: Double // liters
    var equipment: String
    var stage: BatchStage
    var startDate: Date
    var currentStageStartDate: Date
    var estimatedCompletionDate: Date?
    var currentTemperature: Double? // °C
    var progress: Double // 0.0 to 1.0
    var timerParametersData: Data? // Encoded TimerParameters
    var notes: String
    var notificationsEnabled: Bool // Enable/disable notifications for this batch
    
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
        volume: Double,
        equipment: String = "",
        stage: BatchStage = .primary,
        startDate: Date = Date(),
        currentStageStartDate: Date = Date(),
        estimatedCompletionDate: Date? = nil,
        currentTemperature: Double? = nil,
        progress: Double = 0.0,
        timerParameters: TimerParameters? = nil,
        notes: String = "",
        notificationsEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.volume = volume
        self.equipment = equipment
        self.stage = stage
        self.startDate = startDate
        self.currentStageStartDate = currentStageStartDate
        self.estimatedCompletionDate = estimatedCompletionDate
        self.currentTemperature = currentTemperature
        self.progress = progress
        self.notes = notes
        self.notificationsEnabled = notificationsEnabled
        // Set timerParametersData directly to avoid initialization order issues
        if let parameters = timerParameters {
            self.timerParametersData = try? JSONEncoder().encode(parameters)
        } else {
            self.timerParametersData = nil
        }
    }
    
    var daysInCurrentStage: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: currentStageStartDate, to: Date()).day ?? 0
        return max(0, days)
    }
    
    var isActive: Bool {
        return stage != .bottled
    }
}

