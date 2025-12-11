import SwiftUI
import UserNotifications

struct NotificationSettingsSection: View {
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var isLoading = true
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notification Permission")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            HStack {
                Image(systemName: notificationStatus == .authorized ? "bell.fill" : "bell.slash.fill")
                    .foregroundColor(notificationStatus == .authorized ? .green : .red)
                Text(simpleStatusText)
                    .foregroundColor(.white)
                Spacer()
                if notificationStatus != .authorized {
                    Button(action: handleButton) {
                        Text(buttonText)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("ButtonColor"))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 10)
        .onAppear(perform: fetchNotificationStatus)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                // Fetch immediately
                fetchNotificationStatus()
                // Fetch again after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    fetchNotificationStatus()
                }
            }
        }
    }
    
    private var simpleStatusText: String {
        switch notificationStatus {
        case .authorized: return "Granted"
        case .denied: return "Denied"
        case .notDetermined, .provisional, .ephemeral: return "Not Determined"
        @unknown default: return "Not Determined"
        }
    }
    
    private var buttonText: String {
        switch notificationStatus {
        case .authorized: return "Manage"
        case .denied: return "Enable"
        case .notDetermined: return "Enable"
        default: return "Enable"
        }
    }
    
    private func handleButton() {
        switch notificationStatus {
        case .notDetermined:
            requestPermission()
        case .denied, .authorized, .provisional, .ephemeral:
            openSettings()
        @unknown default:
            openSettings()
        }
    }
    
    private func fetchNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationStatus = settings.authorizationStatus
                self.isLoading = false
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                fetchNotificationStatus()
            }
        }
    }
}
