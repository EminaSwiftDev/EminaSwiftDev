//
//  JournalView.swift
//  carpark
//

import SwiftUI

struct LogbookPanel: View {
    @ObservedObject var storageManager: StorageController
    @State private var addUnitVisible = false
    @Environment(\.colorScheme) var currentScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                if storageManager.transportUnits.isEmpty {
                    placeholderView
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(storageManager.transportUnits) { unit in
                            NavigationLink(destination: UnitDetailsPanel(unit: unit, storageManager: storageManager)) {
                                TransportCard(unit: unit)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .background(ColorPalette.backgroundMain(scheme: currentScheme))
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { addUnitVisible = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $addUnitVisible) {
                NewUnitForm(storageManager: storageManager)
            }
        }
    }
    
    private var placeholderView: some View {
        VStack(spacing: 20) {
            Image(systemName: "car.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Vehicles")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add your first vehicle by tapping the + button")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TransportCard: View {
    let unit: TransportUnit
    @Environment(\.colorScheme) var currentScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imageBytes = unit.imageBytes, let image = UIImage(data: imageBytes) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
            } else {
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: unit.category.symbolName)
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.8))
                    )
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(unit.unitName)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text(unit.modelName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let operatorImageBytes = unit.operatorImageBytes, let image = UIImage(data: operatorImageBytes) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                
                HStack(spacing: 16) {
                    Label(unit.category.rawValue, systemImage: unit.category.symbolName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(unit.energyType.rawValue, systemImage: unit.energyType.symbolName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                    Text(unit.operatorName)
                        .font(.subheadline)
                }
                
                Divider()
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: "%.0f km", unit.totalDistanceCovered))
                            .font(.headline)
                        Text("Driven")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: "%.0f L", unit.totalEnergyUsed))
                            .font(.headline)
                        Text("Fuel")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: "%.1f L/100km", unit.efficiencyRate))
                            .font(.headline)
                        Text("Avg")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .background(ColorPalette.backgroundCard(scheme: currentScheme))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
