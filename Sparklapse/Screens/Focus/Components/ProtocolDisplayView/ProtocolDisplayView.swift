import SwiftUI

struct ProtocolDisplayView: View {
    @EnvironmentObject var zenFlowManager: ZenFlowManager
    
    var body: some View {
        HStack(spacing: 8) {
            Text("Focus plan")
                .foregroundColor(Color("PrimaryText"))
            Text("\(Int(zenFlowManager.selectedProtocol.fastingHours)):\(Int(zenFlowManager.selectedProtocol.eatingHours))")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
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
                )
        }
        .font(.system(size: 17))
    }
}

