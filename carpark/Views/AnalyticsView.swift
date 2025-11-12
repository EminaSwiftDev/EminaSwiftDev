//
//  AnalyticsView.swift
//  carpark
//

import SwiftUI
import Charts

struct StatisticsPanel: View {
    @ObservedObject var storageManager: StorageController
    @State private var settingsVisible = false
    @Environment(\.colorScheme) var currentScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    overviewMetrics
                    energyTypeBreakdown
                    categoryDistribution
                    operatorPerformance
                }
                .padding()
            }
            .background(ColorPalette.backgroundMain(scheme: currentScheme))
            .navigationTitle("Analytics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { settingsVisible = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $settingsVisible) {
                ConfigurationPanel(storageManager: storageManager)
            }
        }
    }
    
    private var overviewMetrics: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                MetricDisplay(
                    label: "Total km",
                    figure: String(format: "%.0f", storageManager.aggregatedDistance),
                    symbolName: "road.lanes",
                    tint: .blue
                )
                
                MetricDisplay(
                    label: "Spent",
                    figure: String(format: "%.0f $", storageManager.aggregatedExpenditure),
                    symbolName: "dollarsign.circle.fill",
                    tint: .red
                )
            }
            
            HStack(spacing: 12) {
                MetricDisplay(
                    label: "Fuel",
                    figure: String(format: "%.0f L", storageManager.aggregatedEnergyUsage),
                    symbolName: "fuelpump.fill",
                    tint: .orange
                )
                
                MetricDisplay(
                    label: "Vehicles",
                    figure: "\(storageManager.transportUnits.count)",
                    symbolName: "car.fill",
                    tint: .green
                )
            }
        }
    }
    
    private var energyTypeBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Costs by Fuel Type")
                .font(.headline)
            
            if !storageManager.transportUnits.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(storageManager.expenditureByEnergy().sorted(by: { $0.value > $1.value })), id: \.key) { energyType, expenditure in
                        HStack {
                            Image(systemName: energyType.symbolName)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            Text(energyType.rawValue)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text(String(format: "%.0f $", expenditure))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(ColorPalette.backgroundSecondary(scheme: currentScheme))
                        .cornerRadius(8)
                    }
                }
            } else {
                Text("No data")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .background(ColorPalette.backgroundCard(scheme: currentScheme))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var categoryDistribution: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mileage by Vehicle Type")
                .font(.headline)
            
            if !storageManager.transportUnits.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(storageManager.groupedByCategory().sorted(by: { $0.value.reduce(0) { $0 + $1.totalDistanceCovered } > $1.value.reduce(0) { $0 + $1.totalDistanceCovered } })), id: \.key) { category, units in
                        let distance = units.reduce(0) { $0 + $1.totalDistanceCovered }
                        
                        HStack {
                            Image(systemName: category.symbolName)
                                .foregroundColor(.green)
                                .frame(width: 30)
                            
                            Text(category.rawValue)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text(String(format: "%.0f km", distance))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(ColorPalette.backgroundSecondary(scheme: currentScheme))
                        .cornerRadius(8)
                    }
                }
            } else {
                Text("No data")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .background(ColorPalette.backgroundCard(scheme: currentScheme))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var operatorPerformance: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Driver Statistics")
                .font(.headline)
            
            if !storageManager.transportUnits.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(storageManager.distanceByOperator().sorted(by: { $0.value > $1.value })), id: \.key) { operatorName, distance in
                        let operatorUnits = storageManager.transportUnits.filter { $0.operatorName == operatorName }
                        let expenditure = operatorUnits.reduce(0) { $0 + $1.totalExpenditure }
                        
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.purple)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(operatorName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(String(format: "%.0f km • %.0f $", distance, expenditure))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(ColorPalette.backgroundSecondary(scheme: currentScheme))
                        .cornerRadius(8)
                    }
                }
            } else {
                Text("No data")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .background(ColorPalette.backgroundCard(scheme: currentScheme))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MetricDisplay: View {
    let label: String
    let figure: String
    let symbolName: String
    let tint: Color
    @Environment(\.colorScheme) var currentScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: symbolName)
                    .foregroundColor(tint)
                Spacer()
            }
            
            Text(figure)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorPalette.backgroundCard(scheme: currentScheme))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
