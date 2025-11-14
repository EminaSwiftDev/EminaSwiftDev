//
//  TodayTasksWidget.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI

struct TodayTasksWidget: View {
    let tasks: [Task]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundColor(.accentKvass)
                Text("Today's Tasks")
                    .font(.headline)
                Spacer()
                Text("\(tasks.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentKvass.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            if tasks.isEmpty {
                Text("No tasks for today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(tasks.prefix(3)) { task in
                    TaskRowView(task: task)
                }
                
                if tasks.count > 3 {
                    Text("+ \(tasks.count - 3) more tasks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct TaskRowView: View {
    let task: Task
    
    var body: some View {
        HStack {
            Image(systemName: taskIcon(for: task.taskType))
                .foregroundColor(taskColor(for: task.taskType))
                .frame(width: 20)
            
            Text(task.title)
                .font(.subheadline)
            
            Spacer()
            
            Text(task.dueDate, style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func taskIcon(for type: Task.TaskType) -> String {
        switch type {
        case .yeastFeeding:
            return "leaf.fill"
        case .dryHopping:
            return "drop.fill"
        case .temperatureCheck:
            return "thermometer"
        case .bottling:
            return "bottle.fill"
        case .other:
            return "circle.fill"
        }
    }
    
    private func taskColor(for type: Task.TaskType) -> Color {
        switch type {
        case .yeastFeeding:
            return .green
        case .dryHopping:
            return .orange
        case .temperatureCheck:
            return .red
        case .bottling:
            return .blue
        case .other:
            return .gray
        }
    }
}

#Preview {
    TodayTasksWidget(tasks: [
        Task(title: "Yeast Feeding", dueDate: Date(), taskType: .yeastFeeding),
        Task(title: "Dry Hopping", dueDate: Date().addingTimeInterval(3600), taskType: .dryHopping)
    ])
    .padding()
}

