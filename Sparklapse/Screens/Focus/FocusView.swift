import SwiftUI
import SwiftData

struct FocusView: View {
    @EnvironmentObject var zenFlowManager: ZenFlowManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var appState = AppSparklapseState()
    
    private var endTimeString: String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        
        if zenFlowManager.isZenFlowing {
            guard let endTime = zenFlowManager.currentSession?.endTime else { return "" }
            let dateStr = dateFormatter.string(from: endTime)
            // Split the date string and uppercase only the month
            let components = dateStr.split(separator: " ")
            let formattedDate = "\(components[0]) \(components[1].uppercased())"
            return "ScreenTimer will end at \(timeFormatter.string(from: endTime)) - \(formattedDate)"
        } else if zenFlowManager.isEatingWindow {
            guard let eatingWindowEndTime = zenFlowManager.currentSession?.eatingWindowEndTime else { return "" }
            let dateStr = dateFormatter.string(from: eatingWindowEndTime)
            // Split the date string and uppercase only the month
            let components = dateStr.split(separator: " ")
            let formattedDate = "\(components[0]) \(components[1].uppercased())"
            return "Eating window will end at \(timeFormatter.string(from: eatingWindowEndTime)) - \(formattedDate)"
        }
        return ""
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        Spacer()
                        
                        StatusHeaderView(
                            stateText: getStateText(),
                            subtitleText: zenFlowManager.isZenFlowing || zenFlowManager.isEatingWindow ? endTimeString : "Ready for a new challenge?"
                        )
                        
                        Spacer().frame(height: 40)
                        
                        TimerCircleView()
                            .padding(.bottom, 40)
                        
                        Spacer()
                        
                        ProtocolDisplayView()
                            .padding(.bottom, 80)
                    }
                    .padding()
                }
                
            }
            //.navigationTitle("Focus Mode")
            .navigationBarTitleDisplayMode(.inline)
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
                            
                            Image("bb_item_one")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                
                        }
                        
                        Text("Focus Mode")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(Color("Background"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                appState.incrementSessionCount()
                appState.checkIfShouldPromptForRating()
            }
            .alert("Leave Focus Mode?", isPresented: $zenFlowManager.showEndZenFlowAlert) {
                Button("Cancel", role: .cancel) { }
                Button("End Early?", role: .destructive) {
                    zenFlowManager.endZenFlow()
                }
            } message: {
                Text("Are you sure you want to end your fast early? This will mark today's fast as incomplete.")
            }
            .alert("End Eating Window?", isPresented: $zenFlowManager.showEndEatingWindowAlert) {
                Button("Cancel", role: .cancel) { }
                Button("End Eating Window", role: .destructive) {
                    zenFlowManager.endEatingWindow()
                }
            } message: {
                Text("Are you sure you want to end your eating window early? This will mark today's fast as incomplete. A successful fast requires completing both the fasting and eating window periods.")
            }
            .alert("Start Focus?", isPresented: $zenFlowManager.showStartZenFlowAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Start Focus", role: .none) {
                    zenFlowManager.startZenFlow()
                }
            } message: {
                Text("Your (zenFlowManager.selectedProtocol.name) session is starting! Stay focused and let the timer guide you through this phase.")
            }
        }
    }
    
    private func getStateText() -> String {
        if zenFlowManager.isZenFlowing {
            return "You're crushing distractions!"
        } else if zenFlowManager.isEatingWindow {
            return "You're in eating window!"
        } else {
            return "You're in screen time!"
        }
    }
}

