import SwiftUI

struct TimerCircleView: View {
    @EnvironmentObject var zenFlowManager: ZenFlowManager
    
    var body: some View {
        ZStack {
            // Background circle with tick marks
            ZStack {
                // Background circle - thicker stroke
                Circle()
                    .stroke(lineWidth: 22)
                    .opacity(0.3)
                    .foregroundColor(Color.gray.opacity(0.4))
                
                // Tick marks around the circle
                ForEach(0..<60, id: \.self) { index in
                    Rectangle()
                        .fill(Color(red: 0x3D/255, green: 0xF6/255, blue: 0xE0/255).opacity(0.8))
                        .frame(width: 2, height: index % 5 == 0 ? 12 : 6)
                        .offset(y: -140)
                        .rotationEffect(Angle(degrees: Double(index) * 6))
                        .shadow(color: Color(red: 0x3D/255, green: 0xF6/255, blue: 0xE0/255).opacity(0.3), radius: 2)
                }
            }
            
            // Progress circle with new gradient and glow
            Circle()
                .trim(from: 0.0, to: zenFlowManager.progress)
                .stroke(style: StrokeStyle(lineWidth: 22, lineCap: .round, lineJoin: .round))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0x3D/255, green: 0xF6/255, blue: 0xE0/255),
                            Color(red: 0x43/255, green: 0x93/255, blue: 0xC5/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: zenFlowManager.progress)
                .shadow(color: Color(red: 0x3D/255, green: 0xF6/255, blue: 0xE0/255).opacity(0.5), radius: 8)
            
            // Outer dots (28 points around the circumference)
            ForEach(0..<28, id: \.self) { index in
                Rectangle()
                    .fill(Color(red: 0x3D/255, green: 0xF6/255, blue: 0xE0/255).opacity(0.6))
                    .frame(width: 2, height: 4)
                    .offset(y: -175) // Position further from the main circle (2px gap)
                    .rotationEffect(Angle(degrees: Double(index) * 360.0 / 28.0))
                    .shadow(color: Color(red: 0x3D/255, green: 0xF6/255, blue: 0xE0/255).opacity(0.3), radius: 1)
            }
            
            // Inner content
            VStack(spacing: 30) {
                Text(formatTime(zenFlowManager.timeRemaining))
                    .font(.system(size: 43, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                
                TimerControlButton()
            }
        }
        .frame(width: 320, height: 320)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
