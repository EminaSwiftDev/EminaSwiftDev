//
//  NewBatchView.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI

struct NewBatchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var batchName: String = ""
    @State private var volume: Double = 5.0
    @State private var equipment: String = ""
    @State private var showSmartTimer: Bool = false
    @State private var timerParameters: TimerParameters?
    
    var onCreateBatch: (String, Double, String, TimerParameters?) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Batch Information") {
                    TextField("Batch Name", text: $batchName)
                    HStack {
                        Text("Volume (L)")
                        Spacer()
                        TextField("Volume", value: $volume, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                    TextField("Equipment (optional)", text: $equipment)
                }
                
                Section {
                    Button("Use Smart Timer") {
                        showSmartTimer = true
                    }
                } footer: {
                    Text("Calculate fermentation time based on parameters")
                }
                
                if timerParameters != nil {
                    Section("Smart Timer Parameters") {
                        Text("Temperature: \(Int(timerParameters!.temperature))°C")
                        Text("Initial Sweetness: \(String(format: "%.1f", timerParameters!.initialSweetness))°Bx")
                        Text("Yeast Type: \(timerParameters!.yeastType.displayName)")
                        Text("Estimated Time: \(Int(FermentationCalculator.calculateFermentationTime(parameters: timerParameters!))) days")
                    }
                }
                
                Section {
                    Button("Create Batch") {
                        onCreateBatch(batchName.isEmpty ? "New Batch" : batchName, volume, equipment, timerParameters)
                        dismiss()
                    }
                    .disabled(batchName.isEmpty)
                }
            }
            .navigationTitle("New Batch")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showSmartTimer) {
            SmartTimerView { parameters, name in
                timerParameters = parameters
                if !name.isEmpty {
                    batchName = name
                }
            }
        }
    }
}

#Preview {
    NewBatchView { name, volume, equipment, parameters in
        print("Creating batch: \(name)")
    }
}

