//
//  MainTabView.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            CreateBatchView(selectedTab: $selectedTab)
                .tabItem {
                    Label("New Batch", systemImage: "plus.circle.fill")
                }
                .tag(1)
            
            BatchesHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)
            
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                .tag(3)
        }
        .tint(Color.accentKvass)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToCreateBatchTab"))) { _ in
            selectedTab = 1
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Batch.self, Task.self], inMemory: true)
}

