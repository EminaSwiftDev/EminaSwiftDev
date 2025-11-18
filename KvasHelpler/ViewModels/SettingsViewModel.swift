//
//  SettingsViewModel.swift
//  KvasHelpler
//
//  Created by cybercrot on 13.11.2025.
//

import Foundation
import SwiftUI
import UserNotifications

@Observable
class SettingsViewModel {
    @ObservationIgnored
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    @ObservationIgnored
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    
    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }
    
    @MainActor
    var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    @MainActor
    func checkNotificationStatus() async {
        notificationStatus = await NotificationManager.shared.checkAuthorizationStatus()
    }
    
    @MainActor
    func requestNotificationPermission() async {
        let granted = await NotificationManager.shared.requestAuthorization()
        if granted {
            await checkNotificationStatus()
        }
    }
    
    @MainActor
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

