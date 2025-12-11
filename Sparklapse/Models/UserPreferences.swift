import Foundation
import SwiftData

@Model
final class UserPreferences {
    var selectedProtocol: String = "16:8"
    var notificationsEnabled: Bool = true
    var fastingStartTime: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
    var eatingStartTime: Date = Calendar.current.date(from: DateComponents(hour: 12, minute: 0)) ?? Date()
    var theme: String = "system"
    var hapticFeedbackEnabled: Bool = true
    var soundEnabled: Bool = true
    var reminderInterval: Int = 30
    var lastNotificationDate: Date?
    
    init() {
        self.selectedProtocol = "16:8"
        self.notificationsEnabled = true
        self.fastingStartTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
        self.eatingStartTime = Calendar.current.date(from: DateComponents(hour: 12, minute: 0)) ?? Date()
        self.theme = "system"
        self.hapticFeedbackEnabled = true
        self.soundEnabled = true
        self.reminderInterval = 30
    }
} 
