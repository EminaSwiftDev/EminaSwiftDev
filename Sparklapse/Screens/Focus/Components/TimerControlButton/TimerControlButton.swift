import SwiftUI

struct TimerControlButton: View {
    @EnvironmentObject var zenFlowManager: ZenFlowManager
    
    var body: some View {
        Group {
            if !zenFlowManager.isZenFlowing && !zenFlowManager.isEatingWindow {
                Button(action: {
                    zenFlowManager.showStartZenFlowAlert = true
                }) {
                    Text("START")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0x3D/255, green: 0xF6/255, blue: 0xE0/255),
                                    Color(red: 0x43/255, green: 0x93/255, blue: 0xC5/255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Color(red: 0x3D/255, green: 0xF6/255, blue: 0xE0/255).opacity(0.4), radius: 8, x: 0, y: 4)
                }
            } else {
                Button(action: {
                    if zenFlowManager.isZenFlowing {
                        zenFlowManager.showEndZenFlowAlert = true
                    } else {
                        zenFlowManager.showEndEatingWindowAlert = true
                    }
                }) {
                    Text("STOP")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0x3D/255, green: 0xF6/255, blue: 0xE0/255),
                                    Color(red: 0x43/255, green: 0x93/255, blue: 0xC5/255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Color(red: 0x3D/255, green: 0xF6/255, blue: 0xE0/255).opacity(0.4), radius: 8, x: 0, y: 4)
                }
            }
        }
    }
}

