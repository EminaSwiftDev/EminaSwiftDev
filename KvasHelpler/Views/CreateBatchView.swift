//
//  CreateBatchView.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI
import SwiftData

struct CreateBatchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoriteRecipe.createdAt, order: .reverse) private var favorites: [FavoriteRecipe]
    @Binding var selectedTab: Int
    @State private var viewModel = TimerViewModel()
    @State private var batchName: String = ""
    @State private var equipment: String = ""
    @State private var initialTemperature: Double? = nil
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // Favorites Section
                if !favorites.isEmpty {
                    Section("Load from Favorites") {
                        ForEach(favorites) { favorite in
                            Button {
                                loadFavorite(favorite)
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.accentKvass)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(favorite.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        if let params = favorite.timerParameters {
                                            Text("\(Int(params.temperature))°C • \(params.yeastType.displayName) • \(String(format: "%.1f", favorite.volume))L")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                
                // Batch Information Section
                Section("Batch Information") {
                    TextField("Batch Name", text: $batchName)
                    TextField("Equipment (optional)", text: $equipment)
                    
                    HStack {
                        Text("Initial Temperature (°C)")
                        Spacer()
                        TextField("Temperature", value: $initialTemperature, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                }
                
                // Smart Timer Parameters Section
                Section("Fermentation Temperature") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(Int(viewModel.temperature))°C")
                                .font(.headline)
                            Spacer()
                        }
                        Slider(value: $viewModel.temperature, in: 10...35, step: 0.5)
                            .tint(Color.accentKvass)
                    }
                }
                
                Section("Initial Sweetness") {
                    HStack {
                        Text("°Bx or g/L sugar")
                        Spacer()
                        TextField("Value", value: $viewModel.initialSweetness, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                }
                
                Section("Yeast/Starter Type") {
                    Picker("Type", selection: $viewModel.yeastType) {
                        ForEach(YeastType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }
                
                Section("Yeast Amount") {
                    HStack {
                        Text("Grams or %")
                        Spacer()
                        TextField("Amount", value: $viewModel.yeastAmount, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                }
                
                Section("Wort Volume") {
                    HStack {
                        Text("Liters")
                        Spacer()
                        TextField("Volume", value: $viewModel.volume, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                }
                
                Section("Desired Result") {
                    Picker("Sweetness", selection: $viewModel.desiredSweetness) {
                        ForEach(TimerParameters.SweetnessLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    
                    Picker("Carbonation", selection: $viewModel.desiredCarbonation) {
                        ForEach(TimerParameters.CarbonationLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    
                    Picker("Acidity", selection: $viewModel.desiredAcidity) {
                        ForEach(TimerParameters.AcidityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
                
                // Calculated Time Section
                Section("Calculated Fermentation Time") {
                    HStack {
                        Text("Estimated time:")
                            .font(.headline)
                        Spacer()
                        Text("\(viewModel.calculatedDays) days")
                            .font(.title2)
                            .foregroundColor(.accentKvass)
                    }
                }
                
                // Create Batch Button
                Section {
                    Button(action: createBatch) {
                        HStack {
                            Spacer()
                            Text("Create Batch")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(batchName.isEmpty)
                }
            }
            .navigationTitle("New Batch")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        resetForm()
                    }
                }
            }
            .alert("Batch Created", isPresented: $showSuccessAlert) {
                Button("OK") {
                    resetForm()
                    // Switch to Home tab
                    selectedTab = 0
                }
            } message: {
                Text("Your batch has been created successfully!")
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LoadFavorite"))) { notification in
                if let favorite = notification.object as? FavoriteRecipe {
                    loadFavorite(favorite)
                }
            }
        }
    }
    
    private func createBatch() {
        let parameters = viewModel.createParameters()
        let batch = Batch(
            name: batchName.isEmpty ? "New Batch" : batchName,
            volume: viewModel.volume,
            equipment: equipment,
            currentTemperature: initialTemperature,
            timerParameters: parameters
        )
        
        batch.estimatedCompletionDate = FermentationCalculator.calculateCompletionDate(
            startDate: batch.startDate,
            parameters: parameters
        )
        
        modelContext.insert(batch)
        
        do {
            try modelContext.save()
            print("Batch saved successfully: \(batch.name), ID: \(batch.id), Stage: \(batch.stage), isActive: \(batch.isActive)")
            
            // Ensure the batch is persisted
            try modelContext.save()
            
            // Schedule notification for estimated completion if enabled
            if batch.notificationsEnabled, let completionDate = batch.estimatedCompletionDate {
                _Concurrency.Task {
                    let status = await NotificationManager.shared.checkAuthorizationStatus()
                    if status == .authorized {
                        NotificationManager.shared.scheduleBatchStageNotification(
                            batch: batch,
                            stage: .primary,
                            completionDate: completionDate
                        )
                    }
                }
            }
            
            showSuccessAlert = true
        } catch {
            print("Error saving batch: \(error.localizedDescription)")
        }
    }
    
    private func resetForm() {
        batchName = ""
        equipment = ""
        initialTemperature = nil
        viewModel.reset()
    }
    
    private func loadFavorite(_ favorite: FavoriteRecipe) {
        batchName = favorite.name
        equipment = favorite.equipment
        initialTemperature = favorite.initialTemperature
        viewModel.volume = favorite.volume
        
        if let params = favorite.timerParameters {
            viewModel.temperature = params.temperature
            viewModel.initialSweetness = params.initialSweetness
            viewModel.yeastType = params.yeastType
            viewModel.yeastAmount = params.yeastAmount
            viewModel.desiredSweetness = params.desiredSweetness
            viewModel.desiredCarbonation = params.desiredCarbonation
            viewModel.desiredAcidity = params.desiredAcidity
        }
    }
}

#Preview {
    CreateBatchView(selectedTab: .constant(1))
        .modelContainer(for: [Batch.self, Task.self, FavoriteRecipe.self], inMemory: true)
}

