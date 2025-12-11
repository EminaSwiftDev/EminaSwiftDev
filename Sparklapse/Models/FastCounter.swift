import Foundation
import SwiftData

@Model
final class FastCounter {
    var totalFasts: Int = 0
    var completedFasts: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalFastingHours: Double = 0
    var lastFastDate: Date?
    var totalFastsEverCreated: Int = 0
    
    init() {
        self.totalFasts = 0
        self.completedFasts = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalFastingHours = 0
        self.totalFastsEverCreated = 0
    }
    
    static func fetch(in context: ModelContext) -> FastCounter {
        let descriptor = FetchDescriptor<FastCounter>()
        if let counter = try? context.fetch(descriptor).first {
            print("📊 [CloudKit] Found existing counter with value: \(counter.totalFastsEverCreated)")
            print("📊 [CloudKit] Counter details - Total: \(counter.totalFasts), Completed: \(counter.completedFasts), Current Streak: \(counter.currentStreak)")
            return counter
        }
        print("📊 [CloudKit] No existing counter found, creating new counter")
        let counter = FastCounter()
        context.insert(counter)
        do {
            try context.save()
            print("✅ [CloudKit] Successfully saved new counter to SwiftData")
        } catch {
            print("❌ [CloudKit] Error saving new counter to SwiftData: \(error)")
        }
        return counter
    }
    
    func updateCount(_ newCount: Int, in context: ModelContext) {
        print("📊 [CloudKit] Updating counter from \(self.totalFastsEverCreated) to \(newCount)")
        print("📊 [CloudKit] Previous state - Total: \(self.totalFasts), Completed: \(self.completedFasts)")
        self.totalFastsEverCreated = newCount
        do {
            try context.save()
            print("✅ [CloudKit] Successfully saved counter update to SwiftData")
            print("📊 [CloudKit] New state - Total: \(self.totalFasts), Completed: \(self.completedFasts), Total Ever Created: \(self.totalFastsEverCreated)")
        } catch {
            print("❌ [CloudKit] Error saving counter update to SwiftData: \(error)")
        }
        print("📊 [CloudKit] Counter saved with value: \(newCount)")
    }
} 
