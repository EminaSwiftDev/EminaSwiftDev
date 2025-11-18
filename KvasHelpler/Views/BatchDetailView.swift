//
//  BatchDetailView.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI
import SwiftData

struct BatchDetailView: View {
    @Bindable var batch: Batch
    @Query(sort: \FavoriteRecipe.createdAt, order: .reverse) private var allFavorites: [FavoriteRecipe]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var temperatureInput: String = ""
    @State private var timerValue: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isFavorite: Bool = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Timer Section (if active)
                    if batch.isActive, let completionDate = batch.estimatedCompletionDate {
                        timerSection(completionDate: completionDate)
                    }
                    
                    // Batch Information Section
                    batchInfoSection
                    
                    // Smart Timer Parameters Section
                    if let parameters = batch.timerParameters {
                        timerParametersSection(parameters: parameters)
                    }
                    
                    // Temperature Section
                    temperatureSection
                    
                    // Notifications Section
                    notificationsSection
                    
                    // Delete Button Section
                    deleteButtonSection
                }
                .padding()
            }
            .navigationTitle(batch.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        toggleFavorite()
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .accentKvass)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                initializeTemperature()
                startTimer()
                checkFavoriteStatus()
            }
            .onDisappear {
                stopTimer()
            }
            .alert("Delete Batch", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteBatch()
                }
            } message: {
                Text("Are you sure you want to delete this batch? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Stage Icon and Name
            VStack(spacing: 12) {
                Image(systemName: batch.stage.icon)
                    .font(.system(size: 60))
                    .foregroundColor(Color.colorForStage(batch.stage))
                
                Text(batch.stage.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(batch.progress * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: batch.progress)
                    .tint(Color.colorForStage(batch.stage))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding()
        .background(Color.backgroundColorForStage(batch.stage))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.colorForStage(batch.stage), lineWidth: 2)
        )
    }
    
    // MARK: - Timer Section
    private func timerSection(completionDate: Date) -> some View {
        VStack(spacing: 16) {
            Text("Time Remaining")
                .font(.headline)
            
            if timerValue > 0 {
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Text("\(Int(timerValue / 86400))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.accentKvass)
                        Text("days")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 16) {
                        VStack {
                            Text("\(Int((timerValue.truncatingRemainder(dividingBy: 86400)) / 3600))")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.accentKvass)
                            Text("hours")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(Int((timerValue.truncatingRemainder(dividingBy: 3600)) / 60))")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.accentKvass)
                            Text("minutes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                Text("Fermentation Complete!")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            if let completionDate = batch.estimatedCompletionDate {
                Text("Estimated completion: \(completionDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.accentKvass.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Batch Information Section
    private var batchInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Batch Information")
                .font(.headline)
            
            VStack(spacing: 12) {
                InfoRow(label: "Volume", value: "\(String(format: "%.1f", batch.volume)) L", icon: "drop.fill")
                
                if !batch.equipment.isEmpty {
                    InfoRow(label: "Equipment", value: batch.equipment, icon: "flask.fill")
                }
                
                InfoRow(label: "Start Date", value: batch.startDate.formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                
                InfoRow(label: "Days in Current Stage", value: "\(batch.daysInCurrentStage)", icon: "clock.fill")
                
                if let estimatedDate = batch.estimatedCompletionDate {
                    InfoRow(label: "Estimated Completion", value: estimatedDate.formatted(date: .abbreviated, time: .omitted), icon: "checkmark.circle.fill")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Timer Parameters Section
    private func timerParametersSection(parameters: TimerParameters) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fermentation Parameters")
                .font(.headline)
            
            VStack(spacing: 12) {
                InfoRow(label: "Temperature", value: "\(Int(parameters.temperature))°C", icon: "thermometer")
                InfoRow(label: "Initial Sweetness", value: "\(String(format: "%.1f", parameters.initialSweetness))°Bx", icon: "drop.fill")
                InfoRow(label: "Yeast Type", value: parameters.yeastType.displayName, icon: "leaf.fill")
                InfoRow(label: "Yeast Amount", value: "\(String(format: "%.1f", parameters.yeastAmount)) g", icon: "scalemass.fill")
                InfoRow(label: "Desired Sweetness", value: parameters.desiredSweetness.rawValue, icon: "sparkles")
                InfoRow(label: "Desired Carbonation", value: parameters.desiredCarbonation.rawValue, icon: "bubbles.and.sparkles.fill")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Temperature Section
    private var temperatureSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Temperature")
                .font(.headline)
            
            HStack {
                Image(systemName: "thermometer")
                    .foregroundColor(.red)
                    .font(.title2)
                
                if let currentTemp = batch.currentTemperature {
                    Text("\(String(format: "%.1f", currentTemp))°C")
                        .font(.title3)
                        .fontWeight(.semibold)
                } else {
                    Text("Not set")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                TextField("Temperature (°C)", text: $temperatureInput)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
                    .onChange(of: temperatureInput) { oldValue, newValue in
                        saveTemperature()
                    }
                    .onSubmit {
                        saveTemperature()
                    }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Delete Button Section
    private var deleteButtonSection: some View {
        VStack(spacing: 16) {
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "trash")
                    Text("Delete Batch")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Notifications Section
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications")
                .font(.headline)
            
            Toggle("Enable Notifications", isOn: Binding(
                get: { batch.notificationsEnabled },
                set: { newValue in
                    batch.notificationsEnabled = newValue
                    try? modelContext.save()
                    
                    // Cancel or schedule notifications based on toggle
                    if let completionDate = batch.estimatedCompletionDate {
                        if newValue {
                            // Schedule notification if enabled
                            _Concurrency.Task {
                                let status = await NotificationManager.shared.checkAuthorizationStatus()
                                if status == .authorized {
                                    NotificationManager.shared.scheduleBatchStageNotification(
                                        batch: batch,
                                        stage: batch.stage,
                                        completionDate: completionDate
                                    )
                                }
                            }
                        } else {
                            // Cancel notification if disabled
                            NotificationManager.shared.cancelNotification(identifier: "batch-\(batch.id.uuidString)-\(batch.stage.rawValue)")
                        }
                    }
                }
            ))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Helper Methods
    private func initializeTemperature() {
        if let temp = batch.currentTemperature {
            temperatureInput = String(format: "%.1f", temp)
        }
        updateTimer()
    }
    
    private func saveTemperature() {
        if let temp = Double(temperatureInput), !temperatureInput.isEmpty {
            batch.currentTemperature = temp
            do {
                try modelContext.save()
            } catch {
                print("Error saving temperature: \(error)")
            }
        } else if temperatureInput.isEmpty {
            batch.currentTemperature = nil
            do {
                try modelContext.save()
            } catch {
                print("Error saving temperature: \(error)")
            }
        }
    }
    
    private func updateTimer() {
        guard let completionDate = batch.estimatedCompletionDate else {
            timerValue = 0
            return
        }
        
        let now = Date()
        if completionDate > now {
            timerValue = completionDate.timeIntervalSince(now)
        } else {
            timerValue = 0
        }
    }
    
    private func startTimer() {
        updateTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimer()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkFavoriteStatus() {
        // Check if this batch is already in favorites
        let existingFavorite = allFavorites.first { favorite in
            favorite.name == batch.name &&
            favorite.volume == batch.volume &&
            favorite.equipment == batch.equipment
        }
        isFavorite = existingFavorite != nil
    }
    
    private func toggleFavorite() {
        if isFavorite {
            // Remove from favorites
            if let favorite = allFavorites.first(where: { favorite in
                favorite.name == batch.name &&
                favorite.volume == batch.volume &&
                favorite.equipment == batch.equipment
            }) {
                modelContext.delete(favorite)
                try? modelContext.save()
                isFavorite = false
            }
        } else {
            // Check if already exists to prevent duplicates
            let existingFavorite = allFavorites.first { favorite in
                favorite.name == batch.name &&
                favorite.volume == batch.volume &&
                favorite.equipment == batch.equipment
            }
            
            if existingFavorite == nil {
                // Add to favorites
                let favorite = FavoriteRecipe(
                    name: batch.name,
                    timerParameters: batch.timerParameters,
                    volume: batch.volume,
                    equipment: batch.equipment,
                    initialTemperature: batch.currentTemperature
                )
                
                modelContext.insert(favorite)
                
                do {
                    try modelContext.save()
                    isFavorite = true
                } catch {
                    print("Error saving favorite: \(error)")
                }
            }
        }
    }
    
    private func deleteBatch() {
        // Cancel any scheduled notifications for this batch
        if let completionDate = batch.estimatedCompletionDate {
            NotificationManager.shared.cancelNotification(identifier: "batch-\(batch.id.uuidString)-\(batch.stage.rawValue)")
        }
        
        // Delete related favorites
        let relatedFavorites = allFavorites.filter { favorite in
            favorite.name == batch.name &&
            favorite.volume == batch.volume &&
            favorite.equipment == batch.equipment
        }
        
        for favorite in relatedFavorites {
            modelContext.delete(favorite)
        }
        
        // Delete the batch
        modelContext.delete(batch)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error deleting batch: \(error)")
        }
    }
}

// MARK: - Supporting Views
struct InfoRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentKvass)
                .frame(width: 24)
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    BatchDetailView(
        batch: Batch(
            name: "Rye Kvass #3",
            volume: 5.0,
            equipment: "Glass carboy",
            stage: .primary,
            currentTemperature: 22.0,
            progress: 0.5
        )
    )
    .modelContainer(for: [Batch.self, Task.self], inMemory: true)
}

