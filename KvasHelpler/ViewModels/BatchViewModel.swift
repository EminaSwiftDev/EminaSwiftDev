//
//  BatchViewModel.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class BatchViewModel {
    var batches: [Batch] = []
    var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadBatches()
    }
    
    func loadBatches() {
        guard let modelContext = modelContext else { return }
        let descriptor = FetchDescriptor<Batch>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        do {
            batches = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading batches: \(error)")
        }
    }
    
    func addBatch(_ batch: Batch) {
        guard let modelContext = modelContext else { return }
        modelContext.insert(batch)
        save()
        loadBatches()
    }
    
    func updateBatch(_ batch: Batch) {
        save()
        loadBatches()
    }
    
    func deleteBatch(_ batch: Batch) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(batch)
        save()
        loadBatches()
    }
    
    func deleteAllBatches() {
        guard let modelContext = modelContext else { return }
        for batch in batches {
            modelContext.delete(batch)
        }
        save()
        loadBatches()
    }
    
    var activeBatches: [Batch] {
        batches.filter { $0.isActive }
    }
    
    private func save() {
        guard let modelContext = modelContext else { return }
        do {
            try modelContext.save()
        } catch {
            print("Error saving: \(error)")
        }
    }
}

