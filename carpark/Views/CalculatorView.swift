//
//  CalculatorView.swift
//  carpark
//

import SwiftUI

struct ComputationPanel: View {
    @ObservedObject var storageManager: StorageController
    @Environment(\.colorScheme) var currentScheme
    
    @State private var computationMode: ComputationMode = .estimateCost
    @State private var plannedDistance: String = ""
    @State private var efficiencyValue: String = ""
    @State private var currentEnergy: EnergySource = .gasoline
    @State private var alternativeEnergy: EnergySource = .gas
    @State private var energyUnitPrice: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    modeSelector
                    
                    if computationMode == .estimateCost {
                        costEstimationForm
                    } else {
                        savingsComparisonForm
                    }
                    
                    computationResults
                    suggestionsSection
                }
                .padding()
            }
            .background(ColorPalette.backgroundMain(scheme: currentScheme))
            .navigationTitle("Calculator")
        }
    }
    
    private var modeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calculation Type")
                .font(.headline)
            
            Picker("", selection: $computationMode) {
                Text("Monthly Cost").tag(ComputationMode.estimateCost)
                Text("Fuel Savings").tag(ComputationMode.compareSavings)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var costEstimationForm: some View {
        VStack(spacing: 16) {
            InputField(
                label: "Planned Mileage",
                hint: "e.g.: 2000",
                inputText: $plannedDistance,
                symbolName: "road.lanes"
            )
            
            InputField(
                label: "Average Consumption (L/100km)",
                hint: "e.g.: 8.5",
                inputText: $efficiencyValue,
                symbolName: "gauge.medium"
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Fuel Type", systemImage: "fuelpump.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Fuel Type", selection: $currentEnergy) {
                    ForEach(EnergySource.allCases, id: \.self) { energy in
                        Text(energy.rawValue).tag(energy)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(ColorPalette.backgroundRow(scheme: currentScheme))
                .cornerRadius(10)
            }
            
            InputField(
                label: "Fuel Price ($)",
                hint: String(format: "%.0f", currentEnergy.defaultUnitCost),
                inputText: $energyUnitPrice,
                symbolName: "dollarsign.circle"
            )
        }
    }
    
    private var savingsComparisonForm: some View {
        VStack(spacing: 16) {
            InputField(
                label: "Planned Mileage",
                hint: "e.g.: 2000",
                inputText: $plannedDistance,
                symbolName: "road.lanes"
            )
            
            InputField(
                label: "Average Consumption (L/100km)",
                hint: "e.g.: 8.5",
                inputText: $efficiencyValue,
                symbolName: "gauge.medium"
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Current Fuel", systemImage: currentEnergy.symbolName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Current Fuel", selection: $currentEnergy) {
                    ForEach(EnergySource.allCases, id: \.self) { energy in
                        Text(energy.rawValue).tag(energy)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(ColorPalette.backgroundRow(scheme: currentScheme))
                .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("New Fuel", systemImage: alternativeEnergy.symbolName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("New Fuel", selection: $alternativeEnergy) {
                    ForEach(EnergySource.allCases, id: \.self) { energy in
                        Text(energy.rawValue).tag(energy)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(ColorPalette.backgroundRow(scheme: currentScheme))
                .cornerRadius(10)
            }
        }
    }
    
    private var computationResults: some View {
        VStack(spacing: 16) {
            if computationMode == .estimateCost {
                costResults
            } else {
                savingsResults
            }
        }
    }
    
    private var costResults: some View {
        let distance = Double(plannedDistance) ?? 0
        let efficiency = Double(efficiencyValue) ?? 0
        let unitPrice = Double(energyUnitPrice) ?? currentEnergy.defaultUnitCost
        
        let requiredEnergy = (distance * efficiency) / 100
        let totalExpense = requiredEnergy * unitPrice
        
        return VStack(spacing: 12) {
            ComputationResultCard(
                label: "Fuel Needed",
                result: String(format: "%.1f L", requiredEnergy),
                symbolName: "fuelpump.fill",
                tint: .orange
            )
            
            ComputationResultCard(
                label: "Monthly Cost",
                result: String(format: "%.0f $", totalExpense),
                symbolName: "dollarsign.circle.fill",
                tint: .red
            )
            
            ComputationResultCard(
                label: "Cost per km",
                result: String(format: "%.2f $", distance > 0 ? totalExpense / distance : 0),
                symbolName: "chart.line.uptrend.xyaxis",
                tint: .blue
            )
        }
    }
    
    private var savingsResults: some View {
        let distance = Double(plannedDistance) ?? 0
        let efficiency = Double(efficiencyValue) ?? 0
        
        let requiredEnergy = (distance * efficiency) / 100
        let currentExpense = requiredEnergy * currentEnergy.defaultUnitCost
        let alternativeExpense = requiredEnergy * alternativeEnergy.defaultUnitCost
        let difference = currentExpense - alternativeExpense
        let percentageDiff = currentExpense > 0 ? (difference / currentExpense) * 100 : 0
        
        return VStack(spacing: 12) {
            ComputationResultCard(
                label: "Current Cost",
                result: String(format: "%.0f $", currentExpense),
                symbolName: "dollarsign.circle",
                tint: .red
            )
            
            ComputationResultCard(
                label: "New Cost",
                result: String(format: "%.0f $", alternativeExpense),
                symbolName: "dollarsign.circle.fill",
                tint: .orange
            )
            
            ComputationResultCard(
                label: difference >= 0 ? "Savings" : "Additional Cost",
                result: String(format: "%.0f $ (%.1f%%)", abs(difference), abs(percentageDiff)),
                symbolName: difference >= 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                tint: difference >= 0 ? .green : .red
            )
            
            if difference >= 0 {
                ComputationResultCard(
                    label: "Annual Savings",
                    result: String(format: "%.0f $", difference * 12),
                    symbolName: "calendar",
                    tint: .green
                )
            }
        }
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Based on Your Data")
                .font(.headline)
            
            if !storageManager.transportUnits.isEmpty {
                let averageEfficiency = storageManager.transportUnits.reduce(0.0) { $0 + $1.efficiencyRate } / Double(storageManager.transportUnits.count)
                let averageDistance = storageManager.transportUnits.reduce(0.0) { $0 + $1.totalDistanceCovered } / Double(storageManager.transportUnits.count)
                
                VStack(spacing: 8) {
                    SuggestionCard(
                        symbolName: "gauge.medium",
                        message: String(format: "Fleet average consumption: %.1f L/100km", averageEfficiency)
                    )
                    
                    SuggestionCard(
                        symbolName: "road.lanes",
                        message: String(format: "Average mileage: %.0f km", averageDistance)
                    )
                }
            } else {
                Text("Add vehicles to the journal to get hints")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

enum ComputationMode {
    case estimateCost
    case compareSavings
}

struct InputField: View {
    let label: String
    let hint: String
    @Binding var inputText: String
    let symbolName: String
    @Environment(\.colorScheme) var currentScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: symbolName)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField(hint, text: $inputText)
                .keyboardType(.decimalPad)
                .padding()
                .background(ColorPalette.backgroundRow(scheme: currentScheme))
                .cornerRadius(10)
        }
    }
}

struct ComputationResultCard: View {
    let label: String
    let result: String
    let symbolName: String
    let tint: Color
    @Environment(\.colorScheme) var currentScheme
    
    var body: some View {
        HStack {
            Image(systemName: symbolName)
                .font(.title2)
                .foregroundColor(tint)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(result)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .background(ColorPalette.backgroundCard(scheme: currentScheme))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SuggestionCard: View {
    let symbolName: String
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: symbolName)
                .foregroundColor(.blue)
            Text(message)
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}
