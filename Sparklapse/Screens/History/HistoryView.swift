import SwiftUI
import SwiftData

struct HistoryView: View {
    @EnvironmentObject var zenFlowManager: ZenFlowManager
    @Query private var sessions: [ZenFlowSession]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // All cards in a consistent width container
                        VStack(spacing: 20) {
                            // 1️⃣ Streaks & Best Stats Card
                            StreakCardView(sessions: sessions)
                            
                            // 2️⃣ Last 7 Days Bar Chart
                            WeeklyChartView(sessions: sessions)
                            
                            // 3️⃣ Monthly Overview
                            MonthlyStatsView(sessions: sessions)
                            
                            // 4️⃣ Full History List
                            HistoryListView(sessions: sessions)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .padding(.bottom, 80)  // Add extra bottom padding for tab bar
                }
            }
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
                            
                            Image("bb_item_two")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                
                        }
                        
                        Text("History")
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

// Add this extension to ZenFlowManager
extension ZenFlowManager {
    func isCurrentSession(_ session: ZenFlowSession) -> Bool {
        guard let currentSession = currentSession else { return false }
        return currentSession.startTime == session.startTime
    }
}

#Preview {
    HistoryView()
        .environmentObject(ZenFlowManager(modelContext: try! ModelContainer(for: ZenFlowSession.self).mainContext))
}
