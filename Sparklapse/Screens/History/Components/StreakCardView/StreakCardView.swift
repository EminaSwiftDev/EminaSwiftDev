import SwiftUI

struct StreakCardView: View {
    let sessions: [ZenFlowSession]
    
    private var historyCalculator: HistoryCalculator {
        HistoryCalculator(sessions: sessions)
    }
    
    var currentStreak: Int {
        historyCalculator.calculateCurrentStreak()
    }
    
    var longestStreak: Int {
        historyCalculator.calculateLongestStreak()
    }
    
    var longestFast: Double {
        historyCalculator.calculateLongestFast()
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Phone-Free Streaks")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 30) {
                VStack {
                    Text("\(currentStreak)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text("Current Streak")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                VStack {
                    Text("\(longestStreak)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text("Best Streak")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                VStack {
                    Text(historyCalculator.formatLongestFast(longestFast))
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    Text("Longest Session")
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

