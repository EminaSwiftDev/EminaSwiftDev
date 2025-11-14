//
//  SettingsView.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var viewModel = SettingsViewModel()
    @State private var showDeleteAlert = false
    var onDeleteAll: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
                
                Section {
                    Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
                        .onChange(of: viewModel.notificationsEnabled) { oldValue, newValue in
                            if newValue {
                                _Concurrency.Task {
                                    await viewModel.requestNotificationPermission()
                                    await viewModel.checkNotificationStatus()
                                }
                            }
                        }
                    
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(notificationStatusText)
                            .foregroundColor(notificationStatusColor)
                            .font(.caption)
                    }
                    
                    if viewModel.notificationStatus == .denied {
                        Button("Open Settings") {
                            viewModel.openSettings()
                        }
                    } else if viewModel.notificationStatus == .notDetermined {
                        Button("Request Permission") {
                            _Concurrency.Task {
                                await viewModel.requestNotificationPermission()
                            }
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get reminders for tasks and batch stage completions")
                }
                
                Section("Data") {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete All Data")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                _Concurrency.Task {
                    await viewModel.checkNotificationStatus()
                }
            }
            .alert("Delete All Data", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDeleteAll()
                }
            } message: {
                Text("This will permanently delete all batches and tasks. This action cannot be undone.")
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    private var notificationStatusText: String {
        switch viewModel.notificationStatus {
        case .authorized:
            return "Enabled"
        case .denied:
            return "Denied"
        case .notDetermined:
            return "Not Set"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        @unknown default:
            return "Unknown"
        }
    }
    
    private var notificationStatusColor: Color {
        switch viewModel.notificationStatus {
        case .authorized:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        default:
            return .secondary
        }
    }
}

#Preview {
    SettingsView {
        print("Delete all")
    }
}

