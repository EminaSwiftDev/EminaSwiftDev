//
//  MainView.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Query(sort: \Batch.startDate, order: .reverse) private var batches: [Batch]
    @Query(sort: \Task.dueDate, order: .forward) private var allTasks: [Task]
    @Environment(\.modelContext) private var modelContext
    @State private var showSettings = false
    @State private var showFavorites = false
    
    var todayTasks: [Task] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return allTasks.filter { task in
            !task.isCompleted && task.dueDate >= today && task.dueDate < tomorrow
        }
    }
    
    var activeBatches: [Batch] {
        batches.filter { $0.isActive }
    }
    
    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("KvasHelper")
                .toolbar {
                    toolbarContent
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView {
                        deleteAllData()
                    }
                }
                .sheet(isPresented: $showFavorites) {
                    FavoritesView()
                }
        }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !todayTasks.isEmpty {
                    TodayTasksWidget(tasks: todayTasks)
                        .padding(.horizontal)
                }
                
                if activeBatches.isEmpty {
                    emptyStateView
                } else {
                    batchesListView
                }
            }
            .padding(.vertical)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "flask")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No active batches")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Create your first batch to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private var batchesListView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Batches")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(activeBatches) { batch in
                batchCardView(for: batch)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showFavorites = true
            } label: {
                Image(systemName: "heart.fill")
                    .foregroundColor(.accentKvass)
            }
        }
    }
    
    private func batchCardView(for batch: Batch) -> some View {
        return BatchCardView(batch: batch)
            .padding(.horizontal)
    }
    
    private func deleteAllData() {
        for batch in batches {
            modelContext.delete(batch)
        }
        for task in allTasks {
            modelContext.delete(task)
        }
        
        // Delete all favorites
        let favorites = try? modelContext.fetch(FetchDescriptor<FavoriteRecipe>())
        if let favorites = favorites {
            for favorite in favorites {
                modelContext.delete(favorite)
            }
        }
        
        try? modelContext.save()
    }
}

#Preview {
    MainView()
        .modelContainer(for: [Batch.self, Task.self])
}

