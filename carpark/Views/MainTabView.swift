//
//  MainTabView.swift
//  carpark
//

import SwiftUI

struct NavigationController: View {
    @StateObject private var storageManager = StorageController.instance
    @StateObject private var appearanceManager = AppearanceController.instance
    @State private var currentTab: NavigationTab
    
    init() {
        let preferredTab = StorageController.instance.preferences.initialTab
        _currentTab = State(initialValue: preferredTab)
    }
    
    var body: some View {
        TabView(selection: $currentTab) {
            StatisticsPanel(storageManager: storageManager)
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(NavigationTab.statistics)
            
            LogbookPanel(storageManager: storageManager)
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
                .tag(NavigationTab.logbook)
            
            ComputationPanel(storageManager: storageManager)
                .tabItem {
                    Label("Calculator", systemImage: "function")
                }
                .tag(NavigationTab.computations)
            
            LeaderboardPanel(storageManager: storageManager)
                .tabItem {
                    Label("Hall of Fame", systemImage: "trophy.fill")
                }
                .tag(NavigationTab.leaderboard)
        }
        .accentColor(.blue)
        .preferredColorScheme(appearanceManager.activeStyle.schemePreference)
        .onAppear {
            currentTab = storageManager.preferences.initialTab
        }
    }
}

#Preview {
    NavigationController()
}
