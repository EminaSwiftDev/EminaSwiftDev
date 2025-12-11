import SwiftUI

struct ChallengeCard: View {
    let challenge: Challenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(challenge.challengeDescription)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: challenge.iconName)
                    .font(.title2)
                    .foregroundColor(challenge.isCompleted ? .green : .gray)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(challenge.isCompleted ? Color.green : Color.blue)
                        .frame(width: max(0, min(geometry.size.width * challenge.progressPercentage, geometry.size.width)), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            // Progress Text
            Text("\(challenge.currentProgress)/\(challenge.requirement)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("Background"))
                .shadow(color: Color.black.opacity(0.1), radius: 5)
        )
    }
}
