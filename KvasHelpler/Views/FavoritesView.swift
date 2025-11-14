//
//  FavoritesView.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoriteRecipe.createdAt, order: .reverse) private var favorites: [FavoriteRecipe]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if favorites.isEmpty {
                    emptyStateView
                } else {
                    favoritesListView
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No favorites yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Add batches to favorites from the detail view")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var favoritesListView: some View {
        List {
            ForEach(favorites) { favorite in
                FavoriteRowView(favorite: favorite)
            }
            .onDelete(perform: deleteFavorites)
        }
    }
    
    private func deleteFavorites(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(favorites[index])
        }
        try? modelContext.save()
    }
}

struct FavoriteRowView: View {
    let favorite: FavoriteRecipe
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            loadFavorite()
        } label: {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.accentKvass)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(favorite.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let params = favorite.timerParameters {
                        Text("\(Int(params.temperature))°C • \(params.yeastType.displayName) • \(String(format: "%.1f", favorite.volume))L")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func loadFavorite() {
        // Close favorites view
        dismiss()
        
        // Post notifications to switch tab and load favorite
        NotificationCenter.default.post(
            name: NSNotification.Name("SwitchToCreateBatchTab"),
            object: nil
        )
        
        // Small delay to ensure tab switch happens first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(
                name: NSNotification.Name("LoadFavorite"),
                object: favorite
            )
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: [Batch.self, Task.self, FavoriteRecipe.self], inMemory: true)
}

