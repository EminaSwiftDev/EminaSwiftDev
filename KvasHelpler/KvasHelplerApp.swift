//
//  KvasHelplerApp.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct KvasHelplerApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    
    init() {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
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
        .modelContainer(for: [Batch.self, Task.self, FavoriteRecipe.self])
    }
}

// Notification delegate to handle notifications when app is in foreground
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap
        completionHandler()
    }
}
