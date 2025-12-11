//
//  ContentView.swift
//  Sparklapse
//
//  Created by Ashot Kirakosyan on 29.10.25.
//

//
//  ContentView.swift
//  FastZen
//
//  Created by Ashot Kirakosyan on 20.10.25.
//


import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showMainApp: Bool
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var zenFlowManager: ZenFlowManager
    
    let container: ModelContainer = {
        let schema = Schema([
            ZenFlowSession.self,
            UserPreferences.self,
            Challenge.self,
            FastCounter.self
        ])
        
        print("\n🚀 [ContentView] Initializing FastZen...")
        
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            print("✅ [ContentView] Successfully created local container")
            return container
        } catch {
            print("❌ Error creating ModelContainer: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // Инициализация ZenFlowManager
        let manager = ZenFlowManager(modelContext: container.mainContext)
        self._zenFlowManager = StateObject(wrappedValue: manager)
        
        // Проверка онбординга
        self._showMainApp = State(initialValue: UserDefaults.standard.bool(forKey: "hasSeenOnboarding"))
        
        // Исправляем тайминги
        manager.fixCurrentEatingWindowTiming()
        
        // Инициализация данных
        initializeApp()
    }
    
    private func initializeApp() {
        Task {
            await MainActor.run {
                initializeDefaultChallenges(in: container.mainContext)
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Главный интерфейс
            MainTabView()
                .environmentObject(notificationService)
                .environmentObject(zenFlowManager)
                .modelContainer(container)
                .onAppear {
                    print("[ContentView] Main UI appeared, retry fetch...")
                    zenFlowManager.retryRecoverStateIfNeeded()
                }
                .opacity(showMainApp ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: showMainApp)
                .allowsHitTesting(showMainApp)
            
            // Онбординг
            if !hasSeenOnboarding {
                OnboardingPrimaryView(
                    pages: [
                        OnboardingMainSparklapsePageModel(
                            title: "Welcome to Lumenlane",
                            description: "Track your ScreenTimer sessions, stay consistent, and unlock your full potential — all with a clean, distraction-free experience.\n\nWe'll ask for notification permission to remind you about your ScreenTimer progress.",
                            imageName: "purchaseview-hero"
                        ),
                        OnboardingMainSparklapsePageModel(
                            title: "Let's Get You Started",
                            description: "1. Open Settings Tab.\n2. Select a ScreenTimer Plan (like 16:8, 20:4, or OMAD).\n3. Return to the ScreenTimer tab and press Start.\n\nRemember to complete a ScreenTimer protocol, you need to finish both the ScreenTimer and eating window.",
                            imageName: nil,
                            showsContinue: true,
                            showsPrimaryAction: false,
                            onAppearAction: {
                                NotificationService.shared.initialize()
                            },
                            showsNotificationButton: true
                        ),
                        OnboardingMainSparklapsePageModel(
                            title: "What's Available to You?",
                            description: """
• Unlimited ScreenTimer tracking
• Access to all protocols (16:8, 18:6, 20:4, 23:1)
• Custom protocols (24h, 48h and 72h)
• Unlock achievements to stay motivated
• View detailed ScreenTimer history
""",
                            imageName: nil,
                            showsContinue: true,
                            showsPrimaryAction: false,
                            showsSecondaryAction: false
                        )
                    ],
                    onFinish: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showMainApp = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            hasSeenOnboarding = true
                            print("[ContentView] Onboarding finished, retry fetch...")
                            zenFlowManager.retryRecoverStateIfNeeded()
                        }
                    }
                )
                .opacity(showMainApp ? 0 : 1)
                .animation(.easeInOut(duration: 0.5), value: showMainApp)
                .allowsHitTesting(!showMainApp)
            }
        }
    }
    
    
    private func initializeDefaultChallenges(in context: ModelContext) {
        // Check if we already have challenges
        let descriptor = FetchDescriptor<Challenge>()
        print("\n🏆 [Achievements] Checking for existing challenges...")
        
        // First, try to fetch existing challenges
        guard let existingChallenges = try? context.fetch(descriptor) else {
            print("🏆 [Achievements] No existing challenges found, creating new ones...")
            createInitialChallenges(in: context)
            return
        }
        
        print("🏆 [Achievements] Found \(existingChallenges.count) challenges")
        
        // Always clean up duplicates first
        cleanupDuplicateChallenges(existingChallenges, in: context)
        
        // After cleanup, check if we still have challenges
        if let remainingChallenges = try? context.fetch(descriptor), !remainingChallenges.isEmpty {
            print("🏆 [Achievements] Using existing challenges after cleanup")
            return
        }
        
        // If we get here, we need to create new challenges
        print("\n🏆 [Achievements] Creating initial challenges...")
        createInitialChallenges(in: context)
    }
    
    private func cleanupDuplicateChallenges(_ challenges: [Challenge], in context: ModelContext) {
        print("\n🔄 [Achievements] Starting duplicate cleanup...")
        
        // Group challenges by title
        let groupedChallenges = Dictionary(grouping: challenges) { $0.title }
        var duplicatesRemoved = 0
        
        // For each group of challenges with the same title
        for (title, challenges) in groupedChallenges where challenges.count > 1 {
            print("🔄 [Achievements] Found \(challenges.count) duplicates for '\(title)'")
            
            // Find the challenge with the highest progress
            let bestChallenge = challenges.max(by: { a, b in
                if a.isCompleted != b.isCompleted {
                    return !a.isCompleted // Completed challenges take precedence
                }
                return a.currentProgress < b.currentProgress
            })
            
            // Keep the best one and remove others
            for challenge in challenges {
                if challenge != bestChallenge {
                    print("   - Removing duplicate: \(challenge.title) (\(challenge.currentProgress)/\(challenge.requirement))")
                    context.delete(challenge)
                    duplicatesRemoved += 1
                } else {
                    print("   - Keeping: \(challenge.title) (\(challenge.currentProgress)/\(challenge.requirement))")
                }
            }
        }
        
        // Save changes after removing duplicates
        do {
            try context.save()
            print("✅ [Achievements] Successfully removed \(duplicatesRemoved) duplicate challenges")
        } catch {
            print("❌ [Achievements] Error saving after duplicate cleanup: \(error)")
        }
        
        // Print final stats
        if let remainingChallenges = try? context.fetch(FetchDescriptor<Challenge>()) {
            print("\n🏆 [Achievements] After cleanup: \(remainingChallenges.count) challenges remain")
            let completed = remainingChallenges.filter { $0.isCompleted }.count
            let inProgress = remainingChallenges.filter { !$0.isCompleted && $0.currentProgress > 0 }.count
            print("   - Total challenges: \(remainingChallenges.count)")
            print("   - Completed: \(completed)")
            print("   - In progress: \(inProgress)")
            print("   - Not started: \(remainingChallenges.count - completed - inProgress)")
        }
    }
    
    private func createInitialChallenges(in context: ModelContext) {
        print("\n🏆 [Achievements] Creating initial challenges...")
        
        // Basic Challenges (40)
        let basicChallenges = [
            // Beginner Challenges
            Challenge(title: "First ScreenTimer", challengeDescription: "Complete your first ScreenTimer session", requirement: 1, type: .challenge, iconName: "star.fill"),
            Challenge(title: "ScreenTimer Master", challengeDescription: "Complete 10 ScreenTimer sessions", requirement: 10, type: .challenge, iconName: "star.circle.fill"),
            Challenge(title: "Consistency King", challengeDescription: "Maintain a 7-day ScreenTimer streak", requirement: 7, type: .challenge, iconName: "flame.fill"),
            Challenge(title: "Early Bird", challengeDescription: "Start 5 ScreenTimer sessions before 10 AM", requirement: 5, type: .challenge, iconName: "sunrise.fill"),
            Challenge(title: "Night Owl", challengeDescription: "Start 5 ScreenTimer sessions after 8 PM", requirement: 5, type: .challenge, iconName: "moon.fill"),
            Challenge(title: "Weekend Warrior", challengeDescription: "Complete 10 ScreenTimer sessions during weekends", requirement: 10, type: .challenge, iconName: "calendar.circle.fill"),
            Challenge(title: "Workweek Champion", challengeDescription: "Complete 20 ScreenTimer sessions during workdays", requirement: 20, type: .challenge, iconName: "briefcase.fill"),
            Challenge(title: "16:8 Explorer", challengeDescription: "Complete 5 16:8 ScreenTimer sessions", requirement: 5, type: .challenge, iconName: "clock.fill"),
            Challenge(title: "18:6 Adventurer", challengeDescription: "Complete 5 18:6 ScreenTimer sessions", requirement: 5, type: .challenge, iconName: "clock.badge.fill"),
            Challenge(title: "20:4 Warrior", challengeDescription: "Complete 3 20:4 ScreenTimer sessions", requirement: 3, type: .challenge, iconName: "clock.badge.exclamationmark.fill"),
            
            // Extended ScreenTimer Challenges
            Challenge(title: "48h Explorer", challengeDescription: "Complete a 47:1 ScreenTimer session", requirement: 1, type: .challenge, iconName: "clock.badge.fill"),
            Challenge(title: "48h Warrior", challengeDescription: "Complete 3 ScreenTimer sessions of 45+ hours", requirement: 3, type: .challenge, iconName: "clock.badge.exclamationmark.fill"),
            Challenge(title: "48h Master", challengeDescription: "Complete 5 ScreenTimer sessions of 45+ hours", requirement: 5, type: .challenge, iconName: "clock.badge.exclamationmark.fill"),
            Challenge(title: "72h Explorer", challengeDescription: "Complete a 71:1 ScreenTimer session", requirement: 1, type: .challenge, iconName: "clock.badge.fill"),
            Challenge(title: "72h Warrior", challengeDescription: "Complete 3 ScreenTimer sessions of 65+ hours", requirement: 3, type: .challenge, iconName: "clock.badge.exclamationmark.fill"),
            Challenge(title: "72h Master", challengeDescription: "Complete 5 ScreenTimer sessions of 65+ hours", requirement: 5, type: .challenge, iconName: "clock.badge.exclamationmark.fill")
        ]
        
        // Achievements (40)
        let achievements = [
            // Milestone Achievements
            Challenge(title: "Bronze ScreenTimer", challengeDescription: "Complete 25 ScreenTimer sessions", requirement: 25, type: .achievement, iconName: "medal.fill"),
            Challenge(title: "Silver ScreenTimer", challengeDescription: "Complete 50 ScreenTimer sessions", requirement: 50, type: .achievement, iconName: "medal.fill"),
            Challenge(title: "Gold ScreenTimer", challengeDescription: "Complete 100 ScreenTimer sessions", requirement: 100, type: .achievement, iconName: "medal.fill"),
            Challenge(title: "Platinum ScreenTimer", challengeDescription: "Complete 200 ScreenTimer sessions", requirement: 200, type: .achievement, iconName: "medal.fill"),
            Challenge(title: "Diamond ScreenTimer", challengeDescription: "Complete 500 ScreenTimer sessions", requirement: 500, type: .achievement, iconName: "medal.fill"),
            
            // Extended ScreenTimer Achievements
            Challenge(title: "48h Novice", challengeDescription: "Complete 3 ScreenTimer sessions of 40+ hours", requirement: 3, type: .achievement, iconName: "clock.badge.fill"),
            Challenge(title: "48h Adept", challengeDescription: "Complete 10 ScreenTimer sessions of 40+ hours", requirement: 10, type: .achievement, iconName: "clock.badge.fill"),
            Challenge(title: "48h Expert", challengeDescription: "Complete 25 ScreenTimer sessions of 40+ hours", requirement: 25, type: .achievement, iconName: "clock.badge.fill"),
            
            // Streak Achievements
            Challenge(title: "Week Warrior", challengeDescription: "7-day streak", requirement: 7, type: .achievement, iconName: "flame.fill"),
            Challenge(title: "Fortnight Fighter", challengeDescription: "14-day streak", requirement: 14, type: .achievement, iconName: "flame.fill"),
            Challenge(title: "Monthly Master", challengeDescription: "30-day streak", requirement: 30, type: .achievement, iconName: "flame.fill"),
            
            // Special Achievements
            Challenge(title: "Protocol Explorer", challengeDescription: "Try 3 different protocols", requirement: 3, type: .achievement, iconName: "arrow.triangle.swap"),
            Challenge(title: "Seasonal ScreenTimer", challengeDescription: "ScreenTimer in all 4 seasons", requirement: 4, type: .achievement, iconName: "leaf.fill"),
            Challenge(title: "Year-Round ScreenTimer", challengeDescription: "ScreenTimer in all 12 months", requirement: 12, type: .achievement, iconName: "calendar.circle.fill"),
            Challenge(title: "Zen Master", challengeDescription: "Complete 365 ScreenTimer sessions", requirement: 365, type: .achievement, iconName: "peacesign")
        ]
        
        // Insert all challenges and achievements
        for challenge in basicChallenges + achievements {
            context.insert(challenge)
            print("   - Created: \(challenge.title)")
        }
        
        // After creating challenges, force a save and sync
        do {
            try context.save()
            print("✅ [Achievements] Successfully created and saved \(basicChallenges.count + achievements.count) challenges")
        } catch {
            print("❌ [Achievements] Error saving challenges: \(error)")
        }
    }
}
