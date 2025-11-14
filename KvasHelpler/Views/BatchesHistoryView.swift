//
//  BatchesHistoryView.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI
import SwiftData

struct BatchesHistoryView: View {
    @Query(sort: \Batch.startDate, order: .reverse) private var batches: [Batch]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedFilter: FilterOption = .all
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
    }
    
    var filteredBatches: [Batch] {
        switch selectedFilter {
        case .all:
            return batches
        case .active:
            return batches.filter { $0.isActive }
        case .completed:
            return batches.filter { !$0.isActive }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(FilterOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Batches List
                if filteredBatches.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredBatches) { batch in
                                batchCardView(for: batch)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Batches History")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "flask")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No batches")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Create your first batch to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func batchCardView(for batch: Batch) -> some View {
        return BatchCardView(batch: batch)
    }
}

#Preview {
    BatchesHistoryView()
        .modelContainer(for: [Batch.self, Task.self])
}

