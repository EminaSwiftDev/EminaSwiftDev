//
//  VehicleDetailView.swift
//  carpark
//

import SwiftUI

struct UnitDetailsPanel: View {
    let unit: TransportUnit
    @ObservedObject var storageManager: StorageController
    @State private var addLogVisible = false
    @State private var deleteConfirmVisible = false
    @Environment(\.colorScheme) var currentScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                metricsSection
                logsHistorySection
            }
            .padding()
        }
        .background(ColorPalette.backgroundMain(scheme: currentScheme))
        .navigationTitle(unit.unitName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { addLogVisible = true }) {
                        Label("Add Record", systemImage: "plus")
                    }
                    
                    Button(role: .destructive, action: { deleteConfirmVisible = true }) {
                        Label("Delete Vehicle", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $addLogVisible) {
            TripLogForm(unitIdentifier: unit.id, storageManager: storageManager)
        }
        .alert(isPresented: $deleteConfirmVisible) {
            Alert(
                title: Text("Delete Vehicle?"),
                message: Text("All records for this vehicle will be deleted."),
                primaryButton: .destructive(Text("Delete")) {
                    storageManager.removeUnit(unit)
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            if let imageBytes = unit.imageBytes, let image = UIImage(data: imageBytes) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(16)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: unit.category.symbolName)
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.8))
                    )
            }
            
            VStack(spacing: 8) {
                Text(unit.modelName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 20) {
                    Label(unit.category.rawValue, systemImage: unit.category.symbolName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Label(unit.energyType.rawValue, systemImage: unit.energyType.symbolName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    if let operatorImageBytes = unit.operatorImageBytes, let image = UIImage(data: operatorImageBytes) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    
                    Text(unit.operatorName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var metricsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                MetricDisplay(
                    label: "Kilometers",
                    figure: String(format: "%.0f", unit.totalDistanceCovered),
                    symbolName: "road.lanes",
                    tint: .blue
                )
                
                MetricDisplay(
                    label: "Spent",
                    figure: String(format: "%.0f $", unit.totalExpenditure),
                    symbolName: "dollarsign.circle.fill",
                    tint: .red
                )
            }
            
            HStack(spacing: 12) {
                MetricDisplay(
                    label: "Fuel",
                    figure: String(format: "%.0f L", unit.totalEnergyUsed),
                    symbolName: "fuelpump.fill",
                    tint: .orange
                )
                
                MetricDisplay(
                    label: "Avg",
                    figure: String(format: "%.1f L/100km", unit.efficiencyRate),
                    symbolName: "gauge.medium",
                    tint: .green
                )
            }
        }
    }
    
    private var logsHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Records History")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(unit.tripLogs.count)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            if unit.tripLogs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No records")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: { addLogVisible = true }) {
                        Text("Add first record")
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(unit.tripLogs.sorted(by: { $0.recordDate > $1.recordDate })) { log in
                    TripLogCard(log: log)
                }
            }
        }
    }
}

struct TripLogCard: View {
    let log: TripRecord
    @Environment(\.colorScheme) var currentScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(log.recordDate, style: .date)
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: "%.0f $", log.moneySpent))
                    .font(.headline)
                    .foregroundColor(.red)
            }
            
            HStack(spacing: 20) {
                Label(String(format: "%.0f km", log.distanceTraveled), systemImage: "road.lanes")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Label(String(format: "%.1f L", log.energyConsumed), systemImage: "fuelpump.fill")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            
            if !log.additionalInfo.isEmpty {
                Text(log.additionalInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(ColorPalette.backgroundCard(scheme: currentScheme))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct TripLogForm: View {
    let unitIdentifier: UUID
    @ObservedObject var storageManager: StorageController
    @Environment(\.presentationMode) var closeModal
    
    @State private var logDate = Date()
    @State private var distance = ""
    @State private var energyUsed = ""
    @State private var expenditure = ""
    @State private var remarks = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Trip Data")) {
                    DatePicker("Date", selection: $logDate, displayedComponents: .date)
                    
                    TextField("Kilometers", text: $distance)
                        .keyboardType(.decimalPad)
                    
                    TextField("Liters of fuel", text: $energyUsed)
                        .keyboardType(.decimalPad)
                    
                    TextField("Cost ($)", text: $expenditure)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Notes (optional)")) {
                    TextEditor(text: $remarks)
                        .frame(height: 100)
                }
            }
            .navigationTitle("New Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        closeModal.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        persistLog()
                    }
                    .disabled(distance.isEmpty || energyUsed.isEmpty || expenditure.isEmpty)
                }
            }
        }
    }
    
    private func persistLog() {
        let newLog = TripRecord(
            recordDate: logDate,
            distanceTraveled: Double(distance) ?? 0,
            energyConsumed: Double(energyUsed) ?? 0,
            moneySpent: Double(expenditure) ?? 0,
            additionalInfo: remarks
        )
        
        storageManager.appendTripLog(unitIdentifier: unitIdentifier, log: newLog)
        closeModal.wrappedValue.dismiss()
    }
}
