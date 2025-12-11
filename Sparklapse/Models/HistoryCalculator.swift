import Foundation

class HistoryCalculator {
    private let sessions: [ZenFlowSession]
    
    init(sessions: [ZenFlowSession]) {
        // Filter out invalid sessions (less than 1 minute) during initialization
        self.sessions = sessions.filter { $0.fastingHours >= 0.016667 }
    }
    
    func calculateCurrentStreak() -> Int {
        // Sort sessions by start time (most recent first)
        let sortedSessions = sessions.sorted { $0.startTime > $1.startTime }
        
        print("\n🔄 [STREAK] Calculating current streak...")
        print("🔄 [STREAK] Total sessions to analyze: \(sortedSessions.count)")
        
        guard !sortedSessions.isEmpty else {
            print("❌ [STREAK] No sessions found, returning 0")
            return 0
        }
        
        // First check if most recent session is force-ended
        if let mostRecent = sortedSessions.first {
            print("📊 [STREAK] Most recent session:")
            print("   - Force ended: \(mostRecent.forceEnded)")
            print("   - Completed: \(mostRecent.completed)")
            
            if mostRecent.forceEnded {
                print("❌ [STREAK] Most recent session was force-ended, breaking streak")
                return 0
            }
        }
        
        // If we get here, most recent session wasn't force-ended
        // Count completed sessions until we hit a force-ended one
        var streakCount = 0
        for session in sortedSessions {
            if session.forceEnded {
                print("🛑 [STREAK] Found force-ended session, stopping count at \(streakCount)")
                break
            }
            if session.completed && !session.forceEnded {
                streakCount += 1
                print("✅ [STREAK] Found completed session, streak now: \(streakCount)")
            }
        }
        
        print("📈 [STREAK] Final streak count: \(streakCount)")
        return streakCount
    }
    
    func calculateLongestStreak() -> Int {
        // Sort sessions by start time (most recent first)
        let sortedSessions = sessions.sorted { $0.startTime > $1.startTime }
        
        print("\n📊 [LONGEST STREAK] Calculating longest streak...")
        print("📊 [LONGEST STREAK] Total sessions to analyze: \(sortedSessions.count)")
        
        guard !sortedSessions.isEmpty else {
            print("❌ [LONGEST STREAK] No sessions found, returning 0")
            return 0
        }
        
        var longestStreak = 0
        var currentStreak = 0
        
        // Calculate streaks throughout history
        for session in sortedSessions.reversed() { // Go from oldest to newest
            if session.forceEnded {
                // Force-ended session breaks the streak
                print("🛑 [LONGEST STREAK] Force-ended session found, resetting current streak from \(currentStreak)")
                longestStreak = max(longestStreak, currentStreak)
                currentStreak = 0
            } else if session.completed {
                // Completed session adds to streak
                currentStreak += 1
                print("✅ [LONGEST STREAK] Completed session found, current streak: \(currentStreak)")
                longestStreak = max(longestStreak, currentStreak)
                print("📈 [LONGEST STREAK] Updated longest streak: \(longestStreak)")
            }
        }
        
        // Check final streak
        longestStreak = max(longestStreak, currentStreak)
        print("🏆 [LONGEST STREAK] Final longest streak: \(longestStreak)")
        return longestStreak
    }
    
    func calculateLongestFast() -> Double {
        // Only consider naturally completed sessions for longest fast
        let completedSessions = sessions.filter { $0.completed && !$0.forceEnded }
        return completedSessions.map { $0.fastingHours }.max() ?? 0
    }
    
    func formatLongestFast(_ hours: Double) -> String {
        if hours < 1 {
            let minutes = Int(hours * 60)
            return "\(minutes)m"
        } else {
            let wholeHours = Int(hours)
            let remainingMinutes = Int((hours - Double(wholeHours)) * 60)
            if remainingMinutes > 0 {
                return "\(wholeHours)h \(remainingMinutes)m"
            } else {
                return "\(wholeHours)h"
            }
        }
    }
    
    func calculateMonthlyStats() -> (total: String, average: String, successRate: Double) {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        // Only include sessions that have ended (either completed or force-ended)
        let monthSessions = sessions.filter { session in
            // Must be within this month
            guard session.startTime >= startOfMonth && session.startTime <= endOfMonth else { return false }
            // Must be ended (either completed or force-ended)
            return session.completed || session.forceEnded
        }
        
        // Calculate total fasting hours (not eating window)
        let totalHours = monthSessions.reduce(0.0) { $0 + $1.fastingHours }
        let averageHours = monthSessions.isEmpty ? 0.0 : totalHours / Double(monthSessions.count)
        // Success rate only counts naturally completed sessions
        let successRate = Double(monthSessions.filter { $0.completed && !$0.forceEnded }.count) / Double(monthSessions.count)
        
        return (
            formatDuration(totalHours),
            formatDuration(averageHours),
            successRate.isNaN ? 0 : successRate
        )
    }
    
    private func formatDuration(_ hours: Double) -> String {
        if hours < 1 {
            let minutes = Int(hours * 60)
            return "\(minutes)m"
        } else {
            let wholeHours = Int(hours)
            let remainingMinutes = Int((hours - Double(wholeHours)) * 60)
            if remainingMinutes > 0 {
                return "\(wholeHours)h \(remainingMinutes)m"
            } else {
                return "\(wholeHours)h"
            }
        }
    }
    
    func getLastSevenDaysData(currentSession: ZenFlowSession?) -> [(date: Date, duration: Double, completed: Bool)] {
        let calendar = Calendar.current
        let now = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: now)!
        
        var result: [(date: Date, duration: Double, completed: Bool)] = []
        
        for dayOffset in 0...6 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: now)!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            // Get all completed sessions for this day (excluding the current session if it exists)
            var dayFasts = sessions.filter { session in
                // Skip the current session as we'll handle it separately
                if let currentSession = currentSession, session.startTime == currentSession.startTime {
                    return false
                }
                return session.startTime >= startOfDay && session.startTime < endOfDay
            }
            
            // Add current session if it's for this day
            if let currentSession = currentSession,
               calendar.isDate(currentSession.startTime, inSameDayAs: date) {
                dayFasts.append(currentSession)
            }
            
            // Calculate total duration for the day (only fasting hours, not eating window)
            let totalDuration = dayFasts.reduce(0.0) { sum, session in
                if session.startTime == currentSession?.startTime {
                    // For current session, use the actual elapsed time
                    return sum + (session.fastingHours)
                } else if let endTime = session.endTime {
                    // For completed or force-ended sessions, calculate actual duration
                    let actualDuration = endTime.timeIntervalSince(session.startTime) / 3600
                    return sum + actualDuration
                } else {
                    // Fallback to fastingHours if no end time (shouldn't happen)
                    return sum + session.fastingHours
                }
            }
            
            // A day is considered completed if at least one fast was completed naturally
            let hasCompletedFast = dayFasts.contains { $0.completed && !$0.forceEnded }
            
            result.append((date, totalDuration, hasCompletedFast))
        }
        
        return result.reversed()
    }
} 