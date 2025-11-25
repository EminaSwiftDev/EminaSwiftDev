//
//  ContentView.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI

struct ContentView: View {
   
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    
    init() {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some View {
       MainTabView()
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .task {
                // Request notification permission on first launch if enabled
                if notificationsEnabled {
                    let status = await NotificationManager.shared.checkAuthorizationStatus()
                    if status == .notDetermined {
                        _ = await NotificationManager.shared.requestAuthorization()
                    }
                }
            }
    }
}

#Preview {
    ContentView()
}
