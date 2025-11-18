//
//  SmartTimerView.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI

struct SmartTimerView: View {
    @State private var viewModel = TimerViewModel()
    @Environment(\.dismiss) private var dismiss
    var onCreateBatch: ((TimerParameters, String) -> Void)?
    
    @State private var batchName: String = ""
    @State private var equipment: String = ""
    
    var body: some View {
        NavigationView {
            Form {
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
                
                if onCreateBatch != nil {
                    Section("Create Batch") {
                        TextField("Batch Name", text: $batchName)
                        TextField("Equipment (optional)", text: $equipment)
                        
                        Button("Create Batch") {
                            let parameters = viewModel.createParameters()
                            onCreateBatch?(parameters, batchName.isEmpty ? "New Batch" : batchName)
                            dismiss()
                        }
                        .disabled(batchName.isEmpty)
                    }
                }
            }
            .navigationTitle("Smart Timer")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        viewModel.reset()
                    }
                }
            }
        }
    }
}

#Preview {
    SmartTimerView()
}

