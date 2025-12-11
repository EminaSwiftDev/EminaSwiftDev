import SwiftUI

struct MonthlyStatsView: View {
    let sessions: [ZenFlowSession]
    @EnvironmentObject var zenFlowManager: ZenFlowManager
    
    private var historyCalculator: HistoryCalculator {
        HistoryCalculator(sessions: sessions)
    }
    
    var stats: (total: String, average: String, successRate: Double) {
        // Include all past sessions (completed or force-ended) but exclude current session and invalid fasts
        let pastSessions = sessions.filter { session in
            // Exclude current running session
            if let currentSession = zenFlowManager.currentSession,
               currentSession.startTime == session.startTime,
               zenFlowManager.isZenFlowing {
                return false
            }
            // Filter out sessions shorter than 1 minute
            if session.fastingHours < 0.016667 {
                return false
            }
            return true
        }
        
        let calculator = HistoryCalculator(sessions: pastSessions)
        return calculator.calculateMonthlyStats()
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Monthly Overview")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 30) {
                VStack {
                    Text(stats.total)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    Text("Total Phone-free")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                VStack {
                    Text(stats.average)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    Text("Avg/day")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                VStack {
                    Text("\(Int(stats.successRate * 100))%")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    Text("Goal Success")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("Background"))
                .shadow(color: Color.black.opacity(0.1), radius: 5)
        )
    }
}
