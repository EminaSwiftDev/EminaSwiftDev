import SwiftUI

struct CustomPlanButtonContent: View {
    let hours: Int
    let isSelected: Bool
    @EnvironmentObject var zenFlowManager: ZenFlowManager
    
    private var buttonColor: Color {
        switch hours {
        case 24:
            return Color(red: 0.7, green: 0.6, blue: 0.9) // Lavender
        case 48:
            return Color(red: 0.85, green: 0.7, blue: 0.85) // Purple
        case 72:
            return Color(red: 0.85, green: 0.85, blue: 0.7) // Gold
        default:
            return Color(red: 0.7, green: 0.6, blue: 0.9)
        }
    }
    
    private var fastingHours: Int {
        if isSelected && zenFlowManager.selectedProtocol.fastingHours + zenFlowManager.selectedProtocol.eatingHours == Double(hours) {
            return Int(zenFlowManager.selectedProtocol.fastingHours)
        }
        return 0
    }
    
    private var eatingHours: Int {
        if isSelected && zenFlowManager.selectedProtocol.fastingHours + zenFlowManager.selectedProtocol.eatingHours == Double(hours) {
            return Int(zenFlowManager.selectedProtocol.eatingHours)
        }
        return 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 20) {
                if isSelected && fastingHours > 0 {
                    Text("\(fastingHours)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Text("?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Image(systemName: "clock")
                    .font(.title2)
                    .foregroundColor(.white)
                
                if isSelected && eatingHours > 0 {
                    Text("\(eatingHours)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Text("?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            Text("Custom \(hours)h")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ?
                      buttonColor.opacity(0.4) :
                        buttonColor.opacity(0.25))
        )
    }
}
