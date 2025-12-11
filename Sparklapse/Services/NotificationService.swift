import Foundation
import UserNotifications
import SwiftUI

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    private var isInitialized = false
    
    private init() {
        print("🔔 NotificationService: Initializing...")
    }
    
    func initialize() {
        print("[Onboarding] NotificationService.initialize() called")
        guard !isInitialized else {
            print("🔔 NotificationService: Already initialized")
            return
        }
        
        print("🔔 NotificationService: Requesting authorization...")
        requestAuthorization()
        isInitialized = true
    }
    
    private func requestAuthorization() {
        print("[Onboarding] NotificationService.requestAuthorization() called")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("[Onboarding] Notification permission completion handler fired")
            if granted {
                print("✅ NotificationService: Authorization granted")
                self.clearBadgeCount()
            } else if let error = error {
                print("❌ NotificationService: Authorization error: \(error.localizedDescription)")
            } else {
                print("❌ NotificationService: Authorization denied")
            }
        }
    }
    
    private func clearBadgeCount() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    func scheduleZenFlowNotifications(fastEndTime: Date, eatingWindowEndTime: Date, isEatingWindow: Bool) {
        // Cancel any existing notifications first
        cancelAllNotifications()
        
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        
        // Schedule "ScreenTimer ending soon" notification (30 minutes before ScreenTimer end)
        if !isEatingWindow {
            let fastEndingSoonTime = fastEndTime.addingTimeInterval(-30 * 60)
            if Date() < fastEndingSoonTime {
                let fastEndingSoonContent = UNMutableNotificationContent()
                fastEndingSoonContent.title = "ScreenTimer Ending Soon"
                fastEndingSoonContent.body = "Your ScreenTimer ends in 30 minutes. Get ready for your eating window!"
                fastEndingSoonContent.sound = .default
                
                // Use calendar components to ensure proper time zone handling
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fastEndingSoonTime)
                let fastEndingSoonTrigger = UNCalendarNotificationTrigger(
                    dateMatching: components,
                    repeats: false
                )
                
                let fastEndingSoonRequest = UNNotificationRequest(
                    identifier: "fastEndingSoon",
                    content: fastEndingSoonContent,
                    trigger: fastEndingSoonTrigger
                )
                
                center.add(fastEndingSoonRequest) { error in
                    if let error = error {
                        print("Error scheduling 'fast ending soon' notification: \(error)")
                    } else {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
                        formatter.timeZone = TimeZone.current
                        print("Successfully scheduled 'fast ending soon' notification for \(formatter.string(from: fastEndingSoonTime)) \(TimeZone.current.identifier)")
                        // Verify notification was scheduled
                        self.verifyScheduledNotifications()
                    }
                }
            }
        }
        
        // Schedule fast end notification
        let fastEndContent = UNMutableNotificationContent()
        fastEndContent.title = "ScreenTimer Complete"
        fastEndContent.body = "Congrats! Your ScreenTimer is complete, your eating window is now open. Enjoy your meal!"
        fastEndContent.sound = .default
        
        // Use calendar components to ensure proper time zone handling
        let fastEndComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fastEndTime)
        let fastEndTrigger = UNCalendarNotificationTrigger(
            dateMatching: fastEndComponents,
            repeats: false
        )
        
        let fastEndRequest = UNNotificationRequest(
            identifier: "fastEnd",
            content: fastEndContent,
            trigger: fastEndTrigger
        )
        
        center.add(fastEndRequest) { error in
            if let error = error {
                print("Error scheduling 'fast end' notification: \(error)")
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd hh:mm a"
                formatter.timeZone = TimeZone.current
                print("Successfully scheduled 'fast end' notification for \(formatter.string(from: fastEndTime)) \(TimeZone.current.identifier)")
                // Verify notification was scheduled
                self.verifyScheduledNotifications()
            }
        }
        
        // Schedule eating window end notification
        let eatingWindowEndContent = UNMutableNotificationContent()
        eatingWindowEndContent.title = "ScreenTimer Protocol Complete!"
        eatingWindowEndContent.body = "Awesome job! You've completed your ScreenTimer protocol. Keep up the great work — see you tomorrow!"
        eatingWindowEndContent.sound = .default
        
        // Use calendar components to ensure proper time zone handling
        let eatingWindowEndComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: eatingWindowEndTime)
        let eatingWindowEndTrigger = UNCalendarNotificationTrigger(
            dateMatching: eatingWindowEndComponents,
            repeats: false
        )
        
        let eatingWindowEndRequest = UNNotificationRequest(
            identifier: "eatingWindowEnd",
            content: eatingWindowEndContent,
            trigger: eatingWindowEndTrigger
        )
        
        center.add(eatingWindowEndRequest) { error in
            if let error = error {
                print("Error scheduling 'eating window end' notification: \(error)")
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd hh:mm a"
                formatter.timeZone = TimeZone.current
                print("Successfully scheduled 'eating window end' notification for \(formatter.string(from: eatingWindowEndTime)) \(TimeZone.current.identifier)")
                // Verify notification was scheduled
                self.verifyScheduledNotifications()
            }
        }
    }
    
    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        print("All notifications cancelled")
    }
    
    private func verifyScheduledNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            print("\n=== Scheduled Notifications ===")
            print("Total pending notifications: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd hh:mm a"
                    formatter.timeZone = TimeZone.current
                    print("ID: \(request.identifier)")
                    if let nextTriggerDate = trigger.nextTriggerDate() {
                        print("Next trigger date: \(formatter.string(from: nextTriggerDate)) \(TimeZone.current.identifier)")
                    }
                }
            }
            print("=== End Notification Check ===\n")
        }
    }
    
    func scheduleZenFlowReminder(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "ScreenTimer Reminder"
        content.body = "Don't forget to start your ScreenTimer!"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "fastingReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ NotificationService: Error scheduling reminder: \(error.localizedDescription)")
            } else {
                print("✅ NotificationService: Fasting reminder scheduled for \(date)")
            }
        }
    }
    
    func cancelZenFlowReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["fastingReminder"])
        print("✅ NotificationService: Fasting reminder cancelled")
    }
} 
