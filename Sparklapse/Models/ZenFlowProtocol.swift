import Foundation
import SwiftData
import BackgroundTasks
import SwiftUI

struct ZenFlowProtocol: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    let name: String
    let fastingHours: Double
    let eatingHours: Double
    var color: Color
    
    enum CodingKeys: String, CodingKey {
        case id, name, fastingHours, eatingHours
        case colorRed, colorGreen, colorBlue, colorOpacity
    }
    
    init(name: String, fastingHours: Double, eatingHours: Double, color: Color) {
        self.id = UUID()
        self.name = name
        self.fastingHours = fastingHours
        self.eatingHours = eatingHours
        self.color = color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        fastingHours = try container.decode(Double.self, forKey: .fastingHours)
        eatingHours = try container.decode(Double.self, forKey: .eatingHours)
        
        let red = try container.decode(Double.self, forKey: .colorRed)
        let green = try container.decode(Double.self, forKey: .colorGreen)
        let blue = try container.decode(Double.self, forKey: .colorBlue)
        let opacity = try container.decode(Double.self, forKey: .colorOpacity)
        
        color = Color(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(fastingHours, forKey: .fastingHours)
        try container.encode(eatingHours, forKey: .eatingHours)
        
        let components = color.components
        try container.encode(components.red, forKey: .colorRed)
        try container.encode(components.green, forKey: .colorGreen)
        try container.encode(components.blue, forKey: .colorBlue)
        try container.encode(components.opacity, forKey: .colorOpacity)
    }
    
    static let protocols: [ZenFlowProtocol] = [
        ZenFlowProtocol(name: "13:11", fastingHours: 13, eatingHours: 11, color: Color(red: 0.6, green: 0.4, blue: 0.8)), // Purple
        ZenFlowProtocol(name: "16:8", fastingHours: 16, eatingHours: 8, color: Color(red: 0.96, green: 0.76, blue: 0.76)), // Pink
        ZenFlowProtocol(name: "18:6", fastingHours: 18, eatingHours: 6, color: Color(red: 0.7, green: 0.85, blue: 0.85)), // Mint
        ZenFlowProtocol(name: "20:4", fastingHours: 20, eatingHours: 4, color: Color(red: 0.96, green: 0.87, blue: 0.7)), // Peach
        ZenFlowProtocol(name: "23:1", fastingHours: 23, eatingHours: 1, color: Color(red: 0.5, green: 0.3, blue: 0.6)), // Purple Dark
    ]
    
    static func == (lhs: ZenFlowProtocol, rhs: ZenFlowProtocol) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Color {
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
        return (Double(r), Double(g), Double(b), Double(o))
    }
}

@MainActor
class ZenFlowManager: ObservableObject {
    @Published var selectedProtocol: ZenFlowProtocol = ZenFlowProtocol.protocols[0] {
        didSet {
            saveSelectedProtocol()
        }
    }
    @Published var isZenFlowing = false
    @Published var isEatingWindow = false
    @Published var currentSession: ZenFlowSession?
    @Published var progress: Double = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var timeElapsed: TimeInterval = 0
    @Published var showEndZenFlowAlert = false
    @Published var showEndEatingWindowAlert = false
    @Published var showStartZenFlowAlert = false
    @Published var availableProtocols: [ZenFlowProtocol] = ZenFlowProtocol.protocols {
        didSet {
            saveCustomProtocols()
        }
    }
    
    private var fastingEndTime: Date?
    private var eatingWindowEndTime: Date?
    
    private var timer: Timer?
    private let modelContext: ModelContext
    private var isTransitioning = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        recoverState()
    }
    
    private func recoverState() {
        print("Attempting to recover state...")
        
        // First load custom protocols and selected protocol
        loadCustomProtocols()
        loadSelectedProtocol()
        
        let descriptor = FetchDescriptor<ZenFlowSession>(
            sortBy: [SortDescriptor(\ZenFlowSession.startTime, order: .reverse)]
        )
        
        do {
            let sessions = try modelContext.fetch(descriptor)
            print("Found \(sessions.count) sessions")
            
            if let mostRecentSession = sessions.first {
                print("Most recent session - Start: \(mostRecentSession.startTime), End: \(String(describing: mostRecentSession.endTime)), Eating Window End: \(String(describing: mostRecentSession.eatingWindowEndTime))")
                
                // First check if the session was force-ended
                if mostRecentSession.forceEnded {
                    print("Session was force-ended, keeping as incomplete")
                    currentSession = nil
                    fastingEndTime = nil
                    eatingWindowEndTime = nil
                    isZenFlowing = false
                    isEatingWindow = false
                    
                    // Cancel any existing notifications
                    NotificationService.shared.cancelAllNotifications()
                    return
                }
                
                // Restore the selected protocol based on the current session
                if let matchingProtocol = availableProtocols.first(where: { $0.name == mostRecentSession.protocolName }) {
                    selectedProtocol = matchingProtocol
                    print("Restored selected protocol to: \(selectedProtocol.name)")
                }
                
                // Check if the fast has ended while the app was closed
                let now = Date()
                
                if !mostRecentSession.completed {
                    // If the fast has ended (current time is past the eating window end)
                    if let eatingWindowEndTime = mostRecentSession.eatingWindowEndTime, now > eatingWindowEndTime {
                        print("Session completed naturally during recovery")
                        mostRecentSession.completed = true
                        mostRecentSession.endTime = mostRecentSession.endTime
                        mostRecentSession.eatingWindowEndTime = mostRecentSession.eatingWindowEndTime
                        
                        // Update challenges for the completed fast
                        updateChallenges(for: mostRecentSession)
                        
                        // Save the changes
                        try? modelContext.save()
                        
                        // Reset the current session since this one is completed
                        currentSession = nil
                        self.fastingEndTime = nil
                        self.eatingWindowEndTime = nil
                        isZenFlowing = false
                        isEatingWindow = false
                        
                        // Cancel any existing notifications
                        NotificationService.shared.cancelAllNotifications()
                        
                        print("Recovered completed session state")
                        return
                    }
                    // If the fast is still active but the fasting period has ended (now in eating window)
                    else if let endTime = mostRecentSession.endTime, now > endTime {
                        print("Session in eating window during recovery")
                        currentSession = mostRecentSession
                        self.fastingEndTime = mostRecentSession.endTime
                        self.eatingWindowEndTime = mostRecentSession.eatingWindowEndTime
                        isZenFlowing = false
                        isEatingWindow = true
                        
                        // Cancel existing notifications and schedule only the eating window end notification
                        NotificationService.shared.cancelAllNotifications()
                        if let eatingWindowEndTime = mostRecentSession.eatingWindowEndTime {
                            NotificationService.shared.scheduleZenFlowNotifications(
                                fastEndTime: endTime,
                                eatingWindowEndTime: eatingWindowEndTime,
                                isEatingWindow: true
                            )
                        }
                        
                        // Start the timer to update the UI
                        startTimer()
                        
                        print("Recovered eating window state")
                        return
                    }
                    // If the fast is still active and in the fasting period
                    else {
                        print("Session still active during recovery")
                        currentSession = mostRecentSession
                        self.fastingEndTime = mostRecentSession.endTime
                        self.eatingWindowEndTime = mostRecentSession.eatingWindowEndTime
                        isZenFlowing = true
                        isEatingWindow = false
                        
                        // Cancel existing notifications and reschedule them
                        NotificationService.shared.cancelAllNotifications()
                        
                        if let endTime = mostRecentSession.endTime,
                           let eatingWindowEndTime = mostRecentSession.eatingWindowEndTime {
                            // Reschedule notifications for the active fasting session
                            NotificationService.shared.scheduleZenFlowNotifications(
                                fastEndTime: endTime,
                                eatingWindowEndTime: eatingWindowEndTime,
                                isEatingWindow: false
                            )
                            print("Rescheduled notifications for active fasting session")
                        }
                        
                        // Start the timer to update the UI
                        startTimer()
                        
                        print("Recovered active fasting state")
                        return
                    }
                } else {
                    // Session is already completed
                    print("Session already completed")
                    currentSession = nil
                    fastingEndTime = nil
                    eatingWindowEndTime = nil
                    isZenFlowing = false
                    isEatingWindow = false
                    
                    // Cancel any existing notifications
                    NotificationService.shared.cancelAllNotifications()
                    
                    print("Recovered completed session state")
                }
            } else {
                print("No sessions found")
                currentSession = nil
                fastingEndTime = nil
                eatingWindowEndTime = nil
                isZenFlowing = false
                isEatingWindow = false
                
                // Cancel any existing notifications
                NotificationService.shared.cancelAllNotifications()
            }
        } catch {
            print("Error recovering state: \(error)")
            currentSession = nil
            fastingEndTime = nil
            eatingWindowEndTime = nil
            isZenFlowing = false
            isEatingWindow = false
            
            // Cancel any existing notifications
            NotificationService.shared.cancelAllNotifications()
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func startZenFlow() {
        guard !isZenFlowing && !isEatingWindow else {
            print("❌ [FastingModel] Cannot start fasting while already fasting or in eating window")
            return
        }
        
        let startTime = Date()
        let fastingEndTime = startTime.addingTimeInterval(selectedProtocol.fastingHours * 3600)
        let eatingWindowEndTime = fastingEndTime.addingTimeInterval(selectedProtocol.eatingHours * 3600)
        
        print("\n🕒 [FastingModel] Creating new fasting session:")
        print("   - Protocol: \(selectedProtocol.name)")
        print("   - Fasting hours: \(selectedProtocol.fastingHours)")
        print("   - Eating hours: \(selectedProtocol.eatingHours)")
        
        let session = ZenFlowSession(
            protocolName: selectedProtocol.name,
            startTime: startTime,
            fastingHours: selectedProtocol.fastingHours,
            eatingHours: selectedProtocol.eatingHours
        )
        session.endTime = fastingEndTime
        session.eatingWindowEndTime = eatingWindowEndTime
        
        // Save the session to the model context
        modelContext.insert(session)
        try? modelContext.save()
        print("✅ [FastingModel] Session saved to CloudKit")
        
        // Update the counter
        // counter.updateCount(counter.totalFastsEverCreated + 1, in: modelContext)
        // print("📊 [FastingModel] Updated fast counter: \(counter.totalFastsEverCreated)")
        
        currentSession = session
        isZenFlowing = true
        isEatingWindow = false
        progress = 0
        timeElapsed = 0
        timeRemaining = selectedProtocol.fastingHours * 3600
        
        NotificationService.shared.scheduleZenFlowNotifications(
            fastEndTime: fastingEndTime,
            eatingWindowEndTime: eatingWindowEndTime,
            isEatingWindow: false
        )
        
        startTimer()
        
        // Format dates in local time for logging
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        formatter.timeZone = TimeZone.current
        
        print("=== Starting New Fast ===")
        print("Local Time Details:")
        print("Started at: \(formatter.string(from: startTime))")
        print("Will end at: \(formatter.string(from: fastingEndTime))")
        print("Eating window will end at: \(formatter.string(from: eatingWindowEndTime))")
        print("Time zone: \(TimeZone.current.identifier)")
        print("=== End New Fast Details ===\n")
    }
    
    func endZenFlow(forced: Bool = true) {
        guard let session = currentSession else { return }
        
        let endTime = Date()
        let actualDuration = endTime.timeIntervalSince(session.startTime)
        let actualHours = actualDuration / 3600
        
        // Don't save sessions shorter than 1 minute
        if actualHours < 0.016667 {
            print("🚫 [FastingModel] Session too short (< 1 minute), discarding")
            modelContext.delete(session)
            try? modelContext.save()
            
            currentSession = nil
            isZenFlowing = false
            isEatingWindow = false
            progress = 0
            timeElapsed = 0
            timeRemaining = 0
            
            NotificationService.shared.cancelAllNotifications()
            stopTimer()
            return
        }
        
        // Update session with actual duration
        session.endTime = endTime
        session.fastingHours = actualHours
        session.completed = !forced
        session.forceEnded = forced
        
        // Save the session to the model context
        modelContext.insert(session)
        try? modelContext.save()
        
        print("🔄 [CloudKit] Ending fast session - ID: \(session.id)")
        print("🔄 [CloudKit] Session details:")
        print("   - Protocol: \(session.protocolName)")
        print("   - Actual Duration: \(String(format: "%.2f", actualHours))h")
        print("   - Forced: \(forced)")
        print("   - Completed: \(session.completed)")
        
        // Update the counter only for sessions that are saved
        let counter = FastCounter.fetch(in: modelContext)
        counter.updateCount(counter.totalFastsEverCreated + 1, in: modelContext)
        
        print("🔄 [CloudKit] Fast counter updated after ending session")
        
        currentSession = nil
        isZenFlowing = false
        isEatingWindow = false
        progress = 0
        timeElapsed = 0
        timeRemaining = 0
        
        NotificationService.shared.cancelAllNotifications()
        stopTimer()
        
        // Format dates in local time for logging
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        formatter.timeZone = TimeZone.current
        
        print("=== Fast Session Ended ===")
        print("Local Time Details:")
        print("Started at: \(formatter.string(from: session.startTime))")
        print("Ended at: \(formatter.string(from: endTime))")
        print("Actual Duration: \(String(format: "%.2f", actualHours))h")
        print("Force ended: \(forced)")
        print("Completed: \(session.completed)")
        print("=== End Fast Session Details ===\n")
    }
    
    func endEatingWindow(forced: Bool = true) {
        guard isEatingWindow, let session = currentSession else { return }
        
        let endTime = Date()
        session.eatingWindowEndTime = endTime
        
        if forced {
            session.forceEnded = true
            session.completed = false
            print("Session marked as incomplete due to early eating window end")
        } else {
            // Only mark as completed if eating window completes naturally
            session.completed = true
            print("Session completed successfully")
            
            // Update challenges
            updateChallenges(for: session)
        }
        
        isZenFlowing = false
        isEatingWindow = false
        currentSession = nil
        progress = 0
        timeElapsed = 0
        timeRemaining = 0
        
        NotificationService.shared.cancelAllNotifications()
        stopTimer()
        
        // Save changes
        try? modelContext.save()
        
        print("Eating window ended at \(endTime)")
    }
    
    private func updateChallenges(for session: ZenFlowSession) {
        print("\n=== Updating Challenges ===")
        // Don't update challenges for force-ended or incomplete sessions
        if session.forceEnded || !session.completed {
            print("Skipping challenge updates - Session force-ended: \(session.forceEnded), completed: \(session.completed)")
            return
        }

        let calendar = Calendar.current
        let startHour = calendar.component(.hour, from: session.startTime)
        let isWeekend = calendar.isDateInWeekend(session.startTime)
        let month = calendar.component(.month, from: session.startTime)
        print("Session details - Start hour: \(startHour), Is weekend: \(isWeekend), Month: \(month)")
        
        // Calculate current streak
        let currentStreak = calculateCurrentStreak()
        print("Current streak: \(currentStreak) days")
        
        // Fetch all challenges and achievements
        let fetchDescriptor = FetchDescriptor<Challenge>()
        if let allItems = try? modelContext.fetch(fetchDescriptor) {
            print("Found \(allItems.count) challenges/achievements to update")
            
            // Helper function to get total completed sessions
            func getTotalCompletedSessions() -> Int {
                let sessions = (try? modelContext.fetch(FetchDescriptor<ZenFlowSession>())) ?? []
                return sessions.filter { $0.completed && !$0.forceEnded }.count
            }
            
            // Helper function to get unique months/seasons fasted
            func getUniqueMonthsAndSeasons() -> (months: Set<Int>, seasons: Set<Int>) {
                let sessions = (try? modelContext.fetch(FetchDescriptor<ZenFlowSession>())) ?? []
                let completedSessions = sessions.filter { $0.completed && !$0.forceEnded }
                
                var months = Set<Int>()
                var seasons = Set<Int>()
                
                for session in completedSessions {
                    let month = calendar.component(.month, from: session.startTime)
                    months.insert(month)
                    
                    // Calculate season (1: Winter, 2: Spring, 3: Summer, 4: Fall)
                    let season = ((month + 2) % 12) / 3 + 1
                    seasons.insert(season)
                }
                
                return (months, seasons)
            }
            
            // Helper function to get unique time zones fasted
            func getUniqueTimeZones() -> Set<String> {
                let sessions = (try? modelContext.fetch(FetchDescriptor<ZenFlowSession>())) ?? []
                let completedSessions = sessions.filter { $0.completed && !$0.forceEnded }
                
                var timeZones = Set<String>()
                
                for session in completedSessions {
                    // Get the time zone at the time the fast was completed
                    let timeZone = TimeZone.current.identifier
                    timeZones.insert(timeZone)
                    
                    // Also check if the fast was completed in a different time zone
                    if let endTime = session.endTime {
                        let timeZoneAtEnd = TimeZone.current.identifier
                        if timeZoneAtEnd != timeZone {
                            timeZones.insert(timeZoneAtEnd)
                        }
                    }
                }
                
                return timeZones
            }
            
            // Get total completed sessions once
            let totalCompletedSessions = getTotalCompletedSessions()
            
            for item in allItems {
                let oldProgress = item.currentProgress
                
                // Update progress based on challenge type and title
                switch item.title {
                    // Basic completion challenges - all update simultaneously
                    case "First ScreenTimer", "ScreenTimer Master", "Bronze ScreenTimer", "Silver ScreenTimer", "Gold ScreenTimer", "Platinum ScreenTimer", "Diamond ScreenTimer", "Zen Master", "Half-Year Hero":
                        if totalCompletedSessions >= 1 {
                            item.updateProgress()
                        }
                    
                    // Protocol-specific challenges - all update simultaneously for the same protocol
                    case "16:8 Explorer", "16:8 Novice", "16:8 Adept", "16:8 Expert", "16:8 Master", "16:8 Legend", "16:8 Immortal":
                        if session.protocolName == "16:8" {
                            item.updateProgress()
                        }
                        
                    // 18:6 progression - all update simultaneously
                    case "18:6 Adventurer", "18:6 Novice", "18:6 Adept", "18:6 Expert", "18:6 Master", "18:6 Legend", "18:6 Immortal":
                        if session.protocolName == "18:6" {
                            item.updateProgress()
                        }
                        
                    // 20:4 progression - all update simultaneously
                    case "20:4 Warrior", "20:4 Novice", "20:4 Adept":
                        if session.protocolName == "20:4" {
                            item.updateProgress()
                        }
                        
                    // Extended fasting progression - all update simultaneously based on duration
                    // Adjusted to make these more achievable
                    case "48h Explorer", "48h Warrior", "48h Master", "48h Novice", "48h Adept", "48h Expert":
                        if session.fastingHours >= 40 {
                            item.updateProgress()
                        }
                        
                    case "72h Explorer", "72h Warrior", "72h Master", "72h Novice", "72h Adept", "72h Expert":
                        if session.fastingHours >= 60 {
                            item.updateProgress()
                        }
                        
                    // Time-based challenges - all update simultaneously based on time
                    case "Early Bird", "Early Riser Bronze", "Early Riser Silver", "Early Riser Gold", "Dawn Patrol", "Early Bird Elite":
                        if startHour < 8 {
                            item.updateProgress()
                        }
                        
                    case "Night Owl", "Night Owl Bronze", "Night Owl Silver", "Night Owl Gold", "Midnight Maven", "Night Owl Elite":
                        if startHour >= 20 {
                            item.updateProgress()
                        }
                        
                    // Weekend/Workday challenges - all update simultaneously
                    case "Weekend Warrior", "Weekend Warrior Pro", "Weekend Warrior Elite", "Weekend Immortal", "Weekend Warrior Bronze", "Weekend Warrior Silver", "Weekend Warrior Gold":
                        if isWeekend {
                            item.updateProgress()
                        }
                        
                    case "Workweek Champion", "Workweek Elite", "Workweek Legend", "Workweek Immortal", "Workweek Warrior Bronze", "Workweek Warrior Silver", "Workweek Warrior Gold":
                        if !isWeekend {
                            item.updateProgress()
                        }
                        
                    // Streak-based challenges - all update simultaneously based on current streak
                    case "Consistency King", "Two Week Triumph", "Three Week Titan", "Month Master", "Monthly Master", "Quarter Champion", "Week Warrior", "Fortnight Fighter", "Quarterly Quest":
                        // Update all streak-based challenges based on current streak
                        if currentStreak > 0 {
                            item.updateProgress()
                        }
                    
                    // Protocol variety challenges
                    case "Protocol Explorer", "Protocol Pioneer":
                        let sessions = (try? modelContext.fetch(FetchDescriptor<ZenFlowSession>())) ?? []
                        let completedSessions = sessions.filter { $0.completed && !$0.forceEnded }
                        let uniqueProtocols = Set<String>(completedSessions.map { $0.protocolName })
                        item.currentProgress = uniqueProtocols.count
                        if item.currentProgress >= item.requirement {
                            item.isCompleted = true
                        }
                        
                    // Seasonal and Year-round achievements
                    case "Seasonal Faster":
                        let (_, seasons) = getUniqueMonthsAndSeasons()
                        item.currentProgress = seasons.count
                        if item.currentProgress >= item.requirement {
                            item.isCompleted = true
                        }
                    case "Year-Round Faster":
                        let (months, _) = getUniqueMonthsAndSeasons()
                        item.currentProgress = months.count
                        if item.currentProgress >= item.requirement {
                            item.isCompleted = true
                        }
                    
                    // Time zone achievements
                    case "Time Zone Explorer", "Time Zone Pioneer", "Time Zone Master":
                        let timeZones = getUniqueTimeZones()
                        item.currentProgress = timeZones.count
                        if item.currentProgress >= item.requirement {
                            item.isCompleted = true
                        }
                    
                    // Special achievements
                    case "Extended Fast Pioneer":
                        if session.fastingHours >= 23 || session.fastingHours >= 40 || session.fastingHours >= 60 {
                            item.updateProgress()
                        }
                    case "Extended Fast Elite":
                        if session.fastingHours >= 30 {
                            item.updateProgress()
                        }
                    case "Extended Fast Legend":
                        if session.fastingHours >= 30 {
                            item.updateProgress()
                        }
                    case "ScreenTimer Virtuoso":
                        let totalHours = Int(session.fastingHours)
                        item.currentProgress += totalHours
                        if item.currentProgress >= item.requirement {
                            item.isCompleted = true
                        }
                    
                    default:
                        break
                }
                
                // Log progress changes
                if oldProgress != item.currentProgress {
                    print("Updated \(item.title): \(oldProgress) → \(item.currentProgress)")
                }
            }
            
            do {
                try modelContext.save()
                print("Successfully saved challenge updates")
                
                // Explicitly sync achievements with CloudKit
                syncAchievementsWithCloudKit()
            } catch {
                print("Error saving challenge updates: \(error)")
            }
        }
        print("=== End Challenge Updates ===\n")
    }
    
    // New method to explicitly sync achievements with CloudKit
    private func syncAchievementsWithCloudKit() {
        print("\n🔄 [CloudKit] Syncing achievements with CloudKit...")
        
        // First clean up any duplicates
        cleanupDuplicateAchievements()
        
        // Fetch all challenges
        let descriptor = FetchDescriptor<Challenge>()
        if let challenges = try? modelContext.fetch(descriptor) {
            let completedCount = challenges.filter { $0.isCompleted }.count
            print("🔄 [CloudKit] Syncing \(challenges.count) achievements (\(completedCount) completed)")
            
            // Force a save to ensure CloudKit sync
            do {
                try modelContext.save()
                print("✅ [CloudKit] Successfully synced achievements with CloudKit")
            } catch {
                print("❌ [CloudKit] Error syncing achievements with CloudKit: \(error)")
            }
        }
    }
    
    private func cleanupDuplicateAchievements() {
        print("\n🧹 [Achievements] Starting duplicate cleanup...")
        
        let descriptor = FetchDescriptor<Challenge>()
        guard let challenges = try? modelContext.fetch(descriptor) else { return }
        
        // Group challenges by title
        let groupedChallenges = Dictionary(grouping: challenges) { $0.title }
        var cleanupPerformed = false
        
        // For each group of challenges with the same title
        for (title, duplicates) in groupedChallenges where duplicates.count > 1 {
            print("Found \(duplicates.count) duplicates for '\(title)'")
            
            // Find the challenge with the highest progress
            let bestChallenge = duplicates.max(by: { a, b in
                if a.isCompleted != b.isCompleted {
                    return !a.isCompleted // Completed challenges take precedence
                }
                return a.currentProgress < b.currentProgress
            })
            
            // Keep the best one and remove others
            for challenge in duplicates {
                if challenge != bestChallenge {
                    print("   - Removing duplicate: \(challenge.title) (\(challenge.currentProgress)/\(challenge.requirement))")
                    modelContext.delete(challenge)
                    cleanupPerformed = true
                } else {
                    print("   - Keeping: \(challenge.title) (\(challenge.currentProgress)/\(challenge.requirement))")
                }
            }
        }
        
        if cleanupPerformed {
            do {
                try modelContext.save()
                print("✅ [Achievements] Successfully cleaned up duplicates")
            } catch {
                print("❌ [Achievements] Error saving after cleanup: \(error)")
            }
        } else {
            print("✅ [Achievements] No duplicates found")
        }
    }
    
    private func calculateCurrentStreak() -> Int {
        let fetchDescriptor = FetchDescriptor<ZenFlowSession>(
            sortBy: [SortDescriptor(\ZenFlowSession.startTime, order: .reverse)]
        )
        
        guard let sessions = try? modelContext.fetch(fetchDescriptor),
              !sessions.isEmpty else { return 0 }
        
        // First check if most recent session is force-ended
        if let mostRecent = sessions.first, mostRecent.forceEnded {
            return 0  // Break streak on force-end
        }
        
        // If we get here, most recent session wasn't force-ended
        // Count completed sessions until we hit a force-ended one
        var streakCount = 0
        for session in sessions {
            if session.forceEnded {
                break  // Stop counting at force-ended session
            }
            if session.completed && !session.forceEnded {
                streakCount += 1
            }
        }
        return streakCount
    }
    
    private func isPartOfStreak(_ session: ZenFlowSession) -> Bool {
        let calendar = Calendar.current
        let sessionDate = calendar.startOfDay(for: session.startTime)
        
        // Get the previous day's date
        let previousDay = calendar.date(byAdding: .day, value: -1, to: sessionDate)!
        
        // Check if there was a completed session on the previous day
        let fetchDescriptor = FetchDescriptor<ZenFlowSession>(
            predicate: #Predicate<ZenFlowSession> { session in
                session.startTime >= previousDay &&
                session.startTime < sessionDate &&
                session.completed == true &&
                session.forceEnded == false
            }
        )
        
        if let previousSessions = try? modelContext.fetch(fetchDescriptor) {
            return !previousSessions.isEmpty
        }
        
        return false
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.handleTimerUpdate()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleTimerUpdate() {
        guard let session = currentSession else { return }
        let currentTime = Date()
        
        if isZenFlowing {
            let totalFastingTime = session.fastingHours * 3600
            let elapsedTime = currentTime.timeIntervalSince(session.startTime)
            progress = min(elapsedTime / totalFastingTime, 1.0)
            timeElapsed = elapsedTime
            timeRemaining = max(totalFastingTime - elapsedTime, 0)
            
            if let endTime = session.endTime, currentTime >= endTime && !isTransitioning {
                // Natural transition to eating window
                isTransitioning = true
                
                // Update session state
                isZenFlowing = false
                isEatingWindow = true
                
                // Reset progress for eating window and update end times
                progress = 0
                timeElapsed = 0
                timeRemaining = session.eatingHours * 3600
                
                // Calculate eating window end time based on the original fast end time
                let newEatingWindowEndTime = endTime.addingTimeInterval(session.eatingHours * 3600)
                session.eatingWindowEndTime = newEatingWindowEndTime
                
                // Schedule eating window notification
                NotificationService.shared.cancelAllNotifications()
                NotificationService.shared.scheduleZenFlowNotifications(
                    fastEndTime: endTime,
                    eatingWindowEndTime: newEatingWindowEndTime,
                    isEatingWindow: true
                )
                
                // Save the updated session
                try? modelContext.save()
                
                print("Transitioned to eating window at \(currentTime)")
                print("New eating window end time: \(newEatingWindowEndTime)")
                isTransitioning = false
            }
        } else if isEatingWindow {
            guard let eatingWindowStartTime = session.endTime,
                  let actualEatingWindowEndTime = session.eatingWindowEndTime else {
                // If start or end time is missing, stop the timer (or handle error)
                print("❌ [TIMER] Missing start/end time for eating window in session: \(session.id)")
                stopTimer()
                return
            }

            let totalEatingDuration = actualEatingWindowEndTime.timeIntervalSince(eatingWindowStartTime)
            let elapsedTime = currentTime.timeIntervalSince(eatingWindowStartTime)
            
            // Ensure total duration is positive to avoid division by zero or negative progress
            if totalEatingDuration > 0 {
                progress = min(elapsedTime / totalEatingDuration, 1.0)
            } else {
                progress = 1.0 // Consider it complete if duration is zero or negative
            }
            
            timeElapsed = elapsedTime
            // Calculate remaining time based on the ACTUAL end time
            timeRemaining = max(actualEatingWindowEndTime.timeIntervalSince(currentTime), 0)
            
            if currentTime >= actualEatingWindowEndTime && !isTransitioning {
                // Natural completion of eating window
                endEatingWindow(forced: false)  // This will mark as completed
            }
        }
    }
    
    // Add new function to fix current eating window timing
    func fixCurrentEatingWindowTiming() {
        guard let session = currentSession,
              isEatingWindow,
              let fastEndTime = session.endTime else {
            return
        }
        
        // Calculate the correct eating window end time based on the fast end time
        let correctEatingWindowEndTime = fastEndTime.addingTimeInterval(session.eatingHours * 3600)
        
        // Only update if the current end time is different
        if session.eatingWindowEndTime != correctEatingWindowEndTime {
            print("🔄 [TIMER] Fixing eating window timing:")
            print("   - Fast end time: \(fastEndTime)")
            print("   - Current eating window end: \(session.eatingWindowEndTime?.description ?? "nil")")
            print("   - Correct eating window end: \(correctEatingWindowEndTime)")
            
            // Update the eating window end time
            session.eatingWindowEndTime = correctEatingWindowEndTime
            
            // Reschedule notifications
            NotificationService.shared.cancelAllNotifications()
            NotificationService.shared.scheduleZenFlowNotifications(
                fastEndTime: fastEndTime,
                eatingWindowEndTime: correctEatingWindowEndTime,
                isEatingWindow: true
            )
            
            // Save changes
            try? modelContext.save()
            
            print("✅ [TIMER] Eating window timing fixed")
        }
    }
    
    private func saveSelectedProtocol() {
        if let encoded = try? JSONEncoder().encode(selectedProtocol) {
            UserDefaults.standard.set(encoded, forKey: "selectedProtocol")
        }
    }
    
    private func saveCustomProtocols() {
        let customProtocols = availableProtocols.filter { protocolItem in
            !ZenFlowProtocol.protocols.contains { $0.name == protocolItem.name }
        }
        if let encoded = try? JSONEncoder().encode(customProtocols) {
            UserDefaults.standard.set(encoded, forKey: "customProtocols")
        }
    }
    
    private func loadCustomProtocols() {
        if let data = UserDefaults.standard.data(forKey: "customProtocols"),
           let customProtocols = try? JSONDecoder().decode([ZenFlowProtocol].self, from: data) {
            availableProtocols = ZenFlowProtocol.protocols + customProtocols
        }
    }
    
    private func loadSelectedProtocol() {
        if let data = UserDefaults.standard.data(forKey: "selectedProtocol"),
           let savedProtocol = try? JSONDecoder().decode(ZenFlowProtocol.self, from: data) {
            selectedProtocol = savedProtocol
        }
    }
    
    func retryRecoverStateIfNeeded(maxRetries: Int = 10, delay: TimeInterval = 2) {
        var retries = 0
        func attempt() {
            print("[RetryRecover] Attempt \(retries + 1)/\(maxRetries)...")
            self.recoverState()
            let descriptor = FetchDescriptor<ZenFlowSession>(
                sortBy: [SortDescriptor(\ZenFlowSession.startTime, order: .reverse)]
            )
            let sessions = (try? self.modelContext.fetch(descriptor)) ?? []
            if sessions.isEmpty && retries < maxRetries {
                retries += 1
                print("[RetryRecover] No sessions found, retrying in \(delay)s...")
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    attempt()
                }
            } else if !sessions.isEmpty {
                print("[RetryRecover] Sessions found after \(retries + 1) attempt(s): \(sessions.count) session(s)")
            } else {
                print("[RetryRecover] Max retries reached, still no sessions found.")
            }
        }
        attempt()
    }
}
