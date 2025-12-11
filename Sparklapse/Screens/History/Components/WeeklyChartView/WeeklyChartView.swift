import SwiftUI
import Charts

struct WeeklyChartView: View {
    let sessions: [ZenFlowSession]
    @EnvironmentObject var zenFlowManager: ZenFlowManager
    
    private let chartHeight: CGFloat = 250 // Increased chart height
    private let barWidth: CGFloat = 30 // Adjust as needed
    private let bottomPadding: CGFloat = 20 // Bottom padding
    private let topPadding: CGFloat = 40 // New top padding for text
    
    private var historyCalculator: HistoryCalculator {
        HistoryCalculator(sessions: sessions)
    }
    
    private var maxDuration: Double {
        // Find the maximum duration from the actual data
        let maxDataDuration = weeklyData.map { $0.duration }.max() ?? 0
        
        // Round up to the nearest standard interval
        if maxDataDuration <= 24 {
            return 24.0  // For durations up to 24h
        } else if maxDataDuration <= 48 {
            return 48.0  // For durations up to 48h
        } else {
            return 72.0  // For longer durations
        }
    }
    
    private func barHeight(duration: Double, isInProgress: Bool) -> CGFloat {
        guard duration > 0 else { return 0 }
        let maxHeight: CGFloat = chartHeight - (bottomPadding + topPadding) // Account for both top and bottom padding
        let adjustedDuration = min(duration, maxDuration)  // Cap at maxDuration
        return maxHeight * (adjustedDuration / maxDuration)
    }
    
    private var weeklyData: [(date: Date, duration: Double, completed: Bool)] {
        // Include current session in the data for both fasting and eating window
        let currentSession = (zenFlowManager.isZenFlowing || zenFlowManager.isEatingWindow) ? zenFlowManager.currentSession : nil
        var data = historyCalculator.getLastSevenDaysData(currentSession: currentSession)
        
        // If there's a current session, adjust its duration based on actual elapsed time
        if let currentSession = currentSession,
           let todayData = data.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: currentSession.startTime) }) {
            if zenFlowManager.isZenFlowing {
                // During fasting, show actual elapsed time
                let elapsedHours = zenFlowManager.timeElapsed / 3600
                data[todayData].duration = elapsedHours
            } else if zenFlowManager.isEatingWindow {
                // During eating window, show the completed fasting duration
                data[todayData].duration = currentSession.fastingHours
            }
        }
        
        return data
    }
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last 7 Days Phone-Free")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.bottom, 8) // Add some space between title and chart
            
            VStack(spacing: 0) {
                // Chart area with bars
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(weeklyData, id: \.date) { day in
                        VStack(spacing: 4) {
                            Spacer(minLength: topPadding) // Add top padding here
                            
                            // Bar with rounded corners and gradient
                            RoundedRectangle(cornerRadius: 6)
                                .fill(barGradient(for: day))
                                .frame(width: 24, height: barHeight(duration: day.duration, isInProgress: Calendar.current.isDateInToday(day.date)))
                                .animation(.spring(response: 0.3), value: day.duration)
                            
                            // Day label
                            Text(formatDay(day.date))
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.bottom, bottomPadding) // Add bottom padding here
                        }
                        .frame(maxWidth: .infinity) // This will spread out the bars
                    }
                }
                .frame(height: chartHeight)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("Background"))
                .shadow(color: Color.black.opacity(0.1), radius: 5)
        )
        .onChange(of: zenFlowManager.timeElapsed) { _ in
            if zenFlowManager.isZenFlowing || zenFlowManager.isEatingWindow {
                zenFlowManager.objectWillChange.send()
            }
        }
    }
    
    private func barGradient(for day: (date: Date, duration: Double, completed: Bool)) -> LinearGradient {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(day.date)
        
        if day.duration == 0 {
            return LinearGradient(
                colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        // Check if this day is part of the current fasting session
        if let currentSession = zenFlowManager.currentSession {
            let isPartOfCurrentFast = calendar.isDate(day.date, inSameDayAs: currentSession.startTime) ||
                (zenFlowManager.isZenFlowing && day.date > currentSession.startTime && day.date <= Date())
            
            if isPartOfCurrentFast && (zenFlowManager.isZenFlowing || zenFlowManager.isEatingWindow) {
                return LinearGradient(
                    colors: [.orange, .orange.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        
        // For completed or failed fasts
        if day.completed {
            return LinearGradient(
                colors: [.green, .green.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [.red, .red.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}