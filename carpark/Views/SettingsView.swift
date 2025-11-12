//
//  SettingsView.swift
//  carpark
//

import SwiftUI

struct ConfigurationPanel: View {
    @ObservedObject var storageManager: StorageController
    @StateObject private var appearanceManager = AppearanceController.instance
    @Environment(\.presentationMode) var closeModal
    @State private var confirmDeleteVisible = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $appearanceManager.activeStyle) {
                        ForEach(VisualStyle.allCases, id: \.self) { style in
                            Image(systemName: style.representativeIcon)
                                .tag(style)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    HStack {
                        Spacer()
                        Text(appearanceManager.activeStyle.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                
                Section(header: Text("Home Screen")) {
                    Picker("Default Screen", selection: $storageManager.preferences.initialTab) {
                        Text("Analytics").tag(NavigationTab.statistics)
                        Text("Journal").tag(NavigationTab.logbook)
                        Text("Calculator").tag(NavigationTab.computations)
                        Text("Hall of Fame").tag(NavigationTab.leaderboard)
                    }
                    .onChange(of: storageManager.preferences.initialTab) {
                        storageManager.persistToDisk()
                    }
                }
                
                Section(header: Text("Information")) {
                    HStack {
                        Text("Total Vehicles")
                        Spacer()
                        Text("\(storageManager.transportUnits.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Records")
                        Spacer()
                        Text("\(storageManager.transportUnits.reduce(0) { $0 + $1.tripLogs.count })")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Mileage")
                        Spacer()
                        Text(String(format: "%.0f km", storageManager.aggregatedDistance))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Data")) {
                    Button(action: {
                        confirmDeleteVisible = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                            Text("Delete All Data")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Fleet Tracker")
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        closeModal.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $confirmDeleteVisible) {
                Alert(
                    title: Text("Delete All Data?"),
                    message: Text("This action cannot be undone. All vehicles and records will be deleted."),
                    primaryButton: .destructive(Text("Delete")) {
                        storageManager.eraseAllRecords()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
