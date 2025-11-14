//
//  StatisticsView.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query(sort: \Batch.startDate, order: .reverse) private var batches: [Batch]
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        overviewSection
                        batchesByStageSection
                        volumeStatisticsSection
                        yeastTypeStatisticsSection
                        timeStatisticsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Statistics")
        }
    }
    
    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Batches",
                    value: "\(batches.count)",
                    icon: "flask.fill",
                    color: .accentKvass
                )
                
                StatCard(
                    title: "Active",
                    value: "\(activeBatchesCount)",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Completed",
                    value: "\(completedBatchesCount)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
        }
    }
    
    // MARK: - Batches by Stage Section
    private var batchesByStageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Batches by Stage")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(BatchStage.allCases, id: \.self) { stage in
                    StageStatRow(
                        stage: stage,
                        count: batches.filter { $0.stage == stage }.count,
                        total: batches.count
                    )
                }
            }
            .padding()
            .background(isDarkMode ? Color.white.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Volume Statistics Section
    private var volumeStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Volume Statistics")
                .font(.headline)
            
            VStack(spacing: 12) {
                StatRow(
                    title: "Total Volume",
                    value: String(format: "%.1f L", totalVolume),
                    icon: "drop.fill"
                )
                
                StatRow(
                    title: "Average Volume",
                    value: String(format: "%.1f L", averageVolume),
                    icon: "chart.bar.fill"
                )
                
                StatRow(
                    title: "Largest Batch",
                    value: String(format: "%.1f L", largestBatchVolume),
                    icon: "arrow.up.circle.fill"
                )
            }
            .padding()
            .background(isDarkMode ? Color.white.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Yeast Type Statistics Section
    private var yeastTypeStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Yeast Type Distribution")
                .font(.headline)
            
            let batchesWithYeastType = batches.filter { $0.timerParameters != nil }
            
            if batchesWithYeastType.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No yeast type data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Create batches with smart timer to see distribution")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(isDarkMode ? Color.white.opacity(0.1) : Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
            } else {
                VStack(spacing: 12) {
                    ForEach(YeastType.allCases, id: \.self) { yeastType in
                        let count = batches.filter { batch in
                            batch.timerParameters?.yeastType == yeastType
                        }.count
                        
                        if count > 0 {
                            YeastStatRow(
                                yeastType: yeastType,
                                count: count,
                                total: batchesWithYeastType.count
                            )
                        }
                    }
                }
                .padding()
                .background(isDarkMode ? Color.white.opacity(0.1) : Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Time Statistics Section
    private var timeStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Time Statistics")
                .font(.headline)
            
            VStack(spacing: 12) {
                if let avgDays = averageFermentationDays {
                    StatRow(
                        title: "Avg Fermentation Time",
                        value: String(format: "%.1f days", avgDays),
                        icon: "clock.fill"
                    )
                }
                
                StatRow(
                    title: "Oldest Batch",
                    value: oldestBatchDate,
                    icon: "calendar"
                )
                
                StatRow(
                    title: "Newest Batch",
                    value: newestBatchDate,
                    icon: "calendar.badge.plus"
                )
            }
            .padding()
            .background(isDarkMode ? Color.white.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Computed Properties
    private var activeBatchesCount: Int {
        batches.filter { $0.isActive }.count
    }
    
    private var completedBatchesCount: Int {
        batches.filter { !$0.isActive }.count
    }
    
    private var totalVolume: Double {
        batches.reduce(0) { $0 + $1.volume }
    }
    
    private var averageVolume: Double {
        batches.isEmpty ? 0 : totalVolume / Double(batches.count)
    }
    
    private var largestBatchVolume: Double {
        batches.map { $0.volume }.max() ?? 0
    }
    
    private var averageFermentationDays: Double? {
        let batchesWithParams = batches.compactMap { batch -> (Batch, TimerParameters)? in
            guard let params = batch.timerParameters else { return nil }
            return (batch, params)
        }
        
        guard !batchesWithParams.isEmpty else { return nil }
        
        let totalDays = batchesWithParams.reduce(0.0) { sum, item in
            sum + FermentationCalculator.calculateFermentationTime(parameters: item.1)
        }
        
        return totalDays / Double(batchesWithParams.count)
    }
    
    private var oldestBatchDate: String {
        guard let oldest = batches.min(by: { $0.startDate < $1.startDate }) else {
            return "N/A"
        }
        return oldest.startDate.formatted(date: .abbreviated, time: .omitted)
    }
    
    private var newestBatchDate: String {
        guard let newest = batches.max(by: { $0.startDate < $1.startDate }) else {
            return "N/A"
        }
        return newest.startDate.formatted(date: .abbreviated, time: .omitted)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isDarkMode ? Color.white.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentKvass)
                .frame(width: 24)
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct StageStatRow: View {
    let stage: BatchStage
    let count: Int
    let total: Int
    
    var percentage: Double {
        total > 0 ? Double(count) / Double(total) * 100 : 0
    }
    
    var body: some View {
        HStack {
            Image(systemName: stage.icon)
                .foregroundColor(Color.colorForStage(stage))
                .frame(width: 24)
            Text(stage.displayName)
            Spacer()
            Text("\(count)")
                .fontWeight(.semibold)
            Text("(\(String(format: "%.0f", percentage))%)")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}

struct YeastStatRow: View {
    let yeastType: YeastType
    let count: Int
    let total: Int
    
    var percentage: Double {
        total > 0 ? Double(count) / Double(total) * 100 : 0
    }
    
    var body: some View {
        HStack {
            Text(yeastType.displayName)
            Spacer()
            Text("\(count)")
                .fontWeight(.semibold)
            Text("(\(String(format: "%.0f", percentage))%)")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [Batch.self, Task.self])
}

