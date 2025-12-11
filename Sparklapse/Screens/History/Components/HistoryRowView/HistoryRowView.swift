import SwiftUI

struct HistoryRowView: View {
    let session: ZenFlowSession
    @EnvironmentObject var zenFlowManager: ZenFlowManager
    
    var isInProgress: Bool {
        // Check if this session is the current session and still in progress
        if let currentSession = zenFlowManager.currentSession,
           currentSession.startTime == session.startTime {
            return zenFlowManager.isZenFlowing || zenFlowManager.isEatingWindow
        }
        return false
    }
    
    var statusIcon: some View {
        Group {
            if isInProgress {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            } else if session.completed && !session.forceEnded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(session.startTime, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.white)
                if isInProgress {
                    Text("In Progress")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text(formatDuration(session.fastingHours))
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            statusIcon
        }
        .padding(.vertical, 8)
    }
    
    private func formatDuration(_ hours: Double) -> String {
        // Ignore extremely short durations (less than 1 minute)
        if hours < 0.016667 { // less than 1 minute (1/60 hour)
            return "0m ScreenTimer"
        }
        
        if hours < 1 {
            let minutes = Int(hours * 60)
            return "\(minutes)m ScreenTimer"
        } else {
            let wholeHours = Int(hours)
            let remainingMinutes = Int((hours - Double(wholeHours)) * 60)
            if remainingMinutes > 0 {
                return "\(wholeHours)h \(remainingMinutes)m ScreenTimer"
            } else {
                return "\(wholeHours)h ScreenTimer"
            }
        }
    }
}
