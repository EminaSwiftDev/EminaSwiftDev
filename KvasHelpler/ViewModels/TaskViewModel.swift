//
//  TaskViewModel.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import Foundation
import SwiftData
import SwiftUI
import UserNotifications

@Observable
class TaskViewModel {
    var tasks: [Task] = []
    var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadTasks()
    }
    
    func loadTasks() {
        guard let modelContext = modelContext else { return }
        let descriptor = FetchDescriptor<Task>(sortBy: [SortDescriptor(\.dueDate, order: .forward)])
        do {
            tasks = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading tasks: \(error)")
        }
    }
    
    func addTask(_ task: Task) {
        guard let modelContext = modelContext else { return }
        modelContext.insert(task)
        save()
        loadTasks()
        
        // Schedule notification for the task
        _Concurrency.Task {
            let status = await NotificationManager.shared.checkAuthorizationStatus()
            if status == .authorized {
                NotificationManager.shared.scheduleTaskNotification(task: task)
            }
        }
    }
    
    func updateTask(_ task: Task) {
        save()
        loadTasks()
    }
    
    func deleteTask(_ task: Task) {
        guard let modelContext = modelContext else { return }
        // Cancel notification for the task
        NotificationManager.shared.cancelNotification(identifier: task.id.uuidString)
        modelContext.delete(task)
        save()
        loadTasks()
    }
    
    func deleteAllTasks() {
        guard let modelContext = modelContext else { return }
        for task in tasks {
            modelContext.delete(task)
        }
        save()
        loadTasks()
    }
    
    var todayTasks: [Task] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return tasks.filter { task in
            !task.isCompleted && task.dueDate >= today && task.dueDate < tomorrow
        }
    }
    
    private func save() {
        guard let modelContext = modelContext else { return }
        do {
            try modelContext.save()
        } catch {
            print("Error saving: \(error)")
        }
    }
}

