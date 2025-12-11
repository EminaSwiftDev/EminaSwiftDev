import SwiftUI
import SwiftData

struct ProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var challenges: [Challenge]
    @State private var selectedTab = 0
    
    // Challenge categories
    private enum ChallengeCategory: String {
        case basic = "Basic Challenges"
        case protocolSpecific = "Protocol Challenges"
        case extendedFasting = "Extended ScreenTimer"
        case timeBased = "Time-based Challenges"
        case weekendWorkday = "Weekend & Workday"
        case streak = "Streak Challenges"
        case variety = "Protocol Variety"
    }
    
    // Helper function to get category for a challenge
    private func getCategory(for challenge: Challenge) -> ChallengeCategory {
        if challenge.title.contains("First Phone") || challenge.title.contains("ScreenTimer Master") {
            return .basic
        } else if challenge.title.contains("16:8") || challenge.title.contains("18:6") || challenge.title.contains("20:4") {
            return .protocolSpecific
        } else if challenge.title.contains("48h") || challenge.title.contains("72h") || challenge.title.contains("Extended Phone") {
            return .extendedFasting
        } else if challenge.title.contains("Early") || challenge.title.contains("Night") {
            return .timeBased
        } else if challenge.title.contains("Weekend") || challenge.title.contains("Workweek") {
            return .weekendWorkday
        } else if challenge.title.contains("Consistency") || challenge.title.contains("Week") || challenge.title.contains("Month") || challenge.title.contains("Quarter") {
            return .streak
        } else if challenge.title.contains("Protocol") {
            return .variety
        }
        return .basic
    }
    
    // Helper function to get progression level for sorting
    private func getProgressionLevel(for challenge: Challenge) -> Int {
        if challenge.title.contains("Explorer") || challenge.title.contains("Adventurer") || challenge.title.contains("Warrior") {
            return 0
        } else if challenge.title.contains("Novice") || challenge.title.contains("Bronze") {
            return 1
        } else if challenge.title.contains("Adept") || challenge.title.contains("Silver") {
            return 2
        } else if challenge.title.contains("Expert") || challenge.title.contains("Gold") {
            return 3
        } else if challenge.title.contains("Master") || challenge.title.contains("Elite") {
            return 4
        } else if challenge.title.contains("Legend") || challenge.title.contains("Immortal") {
            return 5
        }
        return 0
    }
    
    // Group and sort challenges
    private var groupedChallenges: [(ChallengeCategory, [Challenge])] {
        let filtered = challenges.filter { challenge in
            if selectedTab == 0 {
                return challenge.type ?? .challenge == .challenge
            } else {
                return challenge.type ?? .challenge == .achievement
            }
        }
        
        // Group by category
        let grouped = Dictionary(grouping: filtered) { getCategory(for: $0) }
        
        // Sort categories
        let sortedCategories: [ChallengeCategory] = [
            .basic,
            .protocolSpecific,
            .extendedFasting,
            .timeBased,
            .weekendWorkday,
            .streak,
            .variety
        ]
        
        // Sort challenges within each category
        return sortedCategories.compactMap { category in
            guard let categoryChallenges = grouped[category] else { return nil }
            let sortedChallenges = categoryChallenges.sorted { first, second in
                // First sort by progression level
                let firstLevel = getProgressionLevel(for: first)
                let secondLevel = getProgressionLevel(for: second)
                if firstLevel != secondLevel {
                    return firstLevel < secondLevel
                }
                // Then sort by completion status (completed challenges at the bottom)
                if first.isCompleted != second.isCompleted {
                    return !first.isCompleted
                }
                // Finally sort by title
                return first.title < second.title
            }
            return (category, sortedChallenges)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Segmented Control
                        HStack(spacing: 0) {
                            Button(action: {
                                selectedTab = 0
                            }) {
                                Text("Challenges")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(selectedTab == 0 ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedTab == 0 ? 
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0x3D/255, green: 0xF6/255, blue: 0xE0/255),
                                                Color(red: 0x43/255, green: 0x93/255, blue: 0xC5/255)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) : LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                selectedTab = 1
                            }) {
                                Text("Achievements")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(selectedTab == 1 ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedTab == 1 ? 
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0x3D/255, green: 0xF6/255, blue: 0xE0/255),
                                                Color(red: 0x43/255, green: 0x93/255, blue: 0xC5/255)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) : LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                        )
                        .padding()
                        
                        // Content
                        LazyVStack(spacing: 24) {
                            if groupedChallenges.isEmpty {
                                Text("No challenges found. Count: \(challenges.count)")
                                    .foregroundColor(.red)
                                    .padding()
                            } else {
                                ForEach(groupedChallenges, id: \.0) { category, challenges in
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(category.rawValue)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(.horizontal)
                                        
                                        ForEach(challenges) { challenge in
                                            ChallengeCard(challenge: challenge)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 80)  // Add padding for tab bar
                }
            }
            // .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0x3D/255, green: 0xF6/255, blue: 0xE0/255),
                                            Color(red: 0x43/255, green: 0x93/255, blue: 0xC5/255)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                            
                            Image("bb_item_four")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                
                        }
                        
                        Text("Progress")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("Background"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// Add this enum to define challenge difficulties
enum ChallengeDifficulty: String, CaseIterable {
    case basic = "Basic"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
}

#Preview {
    ProgressView()
        .modelContainer(for: Challenge.self)
}
