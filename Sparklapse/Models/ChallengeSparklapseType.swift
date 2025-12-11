import Foundation
import SwiftData

enum ChallengeSparklapseType: String, Codable {
    case challenge = "challenge"
    case achievement = "achievement"
}

@Model
final class Challenge {
    var id: String = Foundation.UUID().uuidString
    var title: String = ""
    var challengeDescription: String = ""
    var requirement: Int = 0
    var currentProgress: Int = 0
    var isCompleted: Bool = false
    var type: ChallengeSparklapseType?
    var iconName: String = ""
    
    init(id: String = Foundation.UUID().uuidString,
         title: String = "",
         challengeDescription: String = "",
         requirement: Int = 0,
         currentProgress: Int = 0,
         isCompleted: Bool = false,
         type: ChallengeSparklapseType = .challenge,
         iconName: String = "") {
        self.id = id
        self.title = title
        self.challengeDescription = challengeDescription
        self.requirement = requirement
        self.currentProgress = currentProgress
        self.isCompleted = isCompleted
        self.type = type
        self.iconName = iconName
    }
    
    var progressPercentage: Double {
        guard requirement > 0 else { return 0 }
        return min(1.0, Double(currentProgress) / Double(requirement))
    }
    
    func updateProgress(_ increment: Int = 1) {
        // Ensure progress doesn't exceed requirement
        currentProgress = min(currentProgress + increment, requirement)
        // Update completion status
        if currentProgress >= requirement {
            isCompleted = true
        }
    }
} 
