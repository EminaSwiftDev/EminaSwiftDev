import SwiftUI

struct HistoryListView: View {
    let sessions: [ZenFlowSession]
    @State private var showingAllHistory = false
    @State private var displayLimit = 6  // Changed from 10 to 6
    
    var groupedSessions: [(String, [ZenFlowSession])] {
        let calendar = Calendar.current
        
        // Filter out sessions that are too short (less than 1 minute)
        let validSessions = sessions.filter { $0.fastingHours >= 0.016667 }
        
        let grouped = Dictionary(grouping: validSessions) { session in
            let components = calendar.dateComponents([.year, .month], from: session.startTime)
            return calendar.date(from: components)!
        }
        
        let sortedGroups = grouped.sorted { $0.key > $1.key }
            .map { (date, sessions) in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                return (formatter.string(from: date), sessions.sorted { $0.startTime > $1.startTime })
            }
        
        // If not showing all history, limit the number of sessions displayed
        if !showingAllHistory {
            return sortedGroups.map { month, sessions in
                (month, Array(sessions.prefix(displayLimit)))
            }
        }
        
        return sortedGroups
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Full History")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(groupedSessions, id: \.0) { month, monthSessions in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(month)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        ForEach(monthSessions) { session in
                            HistoryRowView(session: session)
                        }
                    }
                }
            }
            
            // Calculate total valid sessions (longer than 1 minute)
            let validSessions = sessions.filter { $0.fastingHours >= 0.016667 }
            if validSessions.count > displayLimit {
                Divider()
                    .padding(.vertical, 8)
                
                Button(action: {
                    withAnimation {
                        showingAllHistory.toggle()
                    }
                }) {
                    HStack {
                        Text(showingAllHistory ? "Show Less" : "Show More History")
                            .font(.subheadline)
                        Image(systemName: showingAllHistory ? "chevron.up" : "chevron.down")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
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
