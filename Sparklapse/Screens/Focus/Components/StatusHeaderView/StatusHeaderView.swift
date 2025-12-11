import SwiftUI

struct StatusHeaderView: View {
    let stateText: String
    let subtitleText: String
    
    var body: some View {
        VStack {
            Text(stateText)
                .font(.title)
                .foregroundColor(Color("PrimaryText"))
                .bold()
                .multilineTextAlignment(.center)
            
            Text(subtitleText)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.top, 4)
        }
    }
}
