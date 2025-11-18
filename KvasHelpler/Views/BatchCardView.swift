//
//  BatchCardView.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI
import SwiftData

struct BatchCardView: View {
    @Bindable var batch: Batch
    @State private var showDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(batch.name)
                        .font(.headline)
                    Text("\(String(format: "%.1f", batch.volume)) L")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if !batch.equipment.isEmpty {
                        Text(batch.equipment)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Stage indicator
                VStack(spacing: 4) {
                    Image(systemName: batch.stage.icon)
                        .foregroundColor(Color.colorForStage(batch.stage))
                        .font(.title2)
                    Text(batch.stage.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(batch.stage.displayName): \(batch.daysInCurrentStage) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    if let estimatedDate = batch.estimatedCompletionDate {
                        Text("Est: \(estimatedDate, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                ProgressView(value: batch.progress)
                    .tint(Color.colorForStage(batch.stage))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
            
            // Temperature display
            HStack {
                Image(systemName: "thermometer")
                    .foregroundColor(.red)
                
                if let currentTemp = batch.currentTemperature {
                    Text("\(String(format: "%.1f", currentTemp))°C")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("No temperature set")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Reminders/Events icons
                if batch.stage == .secondary {
                    Label("Dry Hopping: Tomorrow", systemImage: "drop.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color.backgroundColorForStage(batch.stage))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.colorForStage(batch.stage), lineWidth: 2)
        )
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            BatchDetailView(batch: batch)
        }
    }
}

#Preview {
    BatchCardView(
        batch: Batch(
            name: "Rye Kvass #3",
            volume: 5.0,
            equipment: "Glass carboy",
            stage: .primary,
            progress: 0.5
        )
    )
    .modelContainer(for: [Batch.self, Task.self, FavoriteRecipe.self], inMemory: true)
    .padding()
}

