//
//  Task.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import Foundation
import SwiftData

@Model
final class Task {
    var id: UUID
    var title: String
    var batchId: UUID?
    var dueDate: Date
    var isCompleted: Bool
    var taskType: TaskType
    
    enum TaskType: String, Codable {
        case yeastFeeding = "Yeast Feeding"
        case dryHopping = "Dry Hopping"
        case temperatureCheck = "Temperature Check"
        case bottling = "Bottling"
        case other = "Other"
    }
    
    init(id: UUID = UUID(), title: String, batchId: UUID? = nil, dueDate: Date, isCompleted: Bool = false, taskType: TaskType = .other) {
        self.id = id
        self.title = title
        self.batchId = batchId
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.taskType = taskType
    }
}

