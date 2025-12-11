import SwiftUI

struct OnboardingPageSparklapse: View {
    let model: OnboardingMainSparklapsePageModel
    let onContinue: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer().frame(height: 100) // Ensures consistent header height for all screens
            if let imageName = model.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 180, maxHeight: 180)
                    .padding(.bottom, 8)
            }
            Text(model.title)
                .font(.largeTitle).bold()
                .multilineTextAlignment(.center)
                .foregroundColor(Color("PrimaryText"))
            Text(model.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color("PrimaryText").opacity(0.8))
                .padding(.horizontal)
            Spacer()
            if let customContent = model.customContent {
                customContent()
            } else {
                // Notification permission button for onboarding second screen
                if model.showsNotificationButton {
                    Button(action: {
                        NotificationService.shared.initialize()
                    }) {
                        Text("Enable Notifications")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("ButtonColor"))
                    .padding(.horizontal, 32)
                    Button("Continue") {
                        onContinue?()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                    .tint(Color("ButtonColor"))
                    .font(.headline)
                }
                // Purchase button for last screen
                else {
                    if model.showsPrimaryAction, let primaryTitle = model.primaryActionTitle, let primaryAction = model.primaryAction {
                        Button(primaryTitle, action: primaryAction)
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .padding(.horizontal, 32)
                            .tint(Color("ButtonColor"))
                            .font(.headline)
                    }
                    if model.showsContinue {
                        Button("Continue") {
                            onContinue?()
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 24)
                        .tint(Color("ButtonColor"))
                        .font(.headline)
                    }
                    if model.showsSecondaryAction, let secondaryTitle = model.secondaryActionTitle, let secondaryAction = model.secondaryAction {
                        Button(secondaryTitle, action: secondaryAction)
                            .buttonStyle(.plain)
                            .foregroundColor(.accentColor)
                            .padding(.top, 8)
                    }
                }
            }
        }
        .padding()
        .background(Color("Background"))
        .ignoresSafeArea()
        .onAppear {
            model.onAppearAction?()
        }
    }
}

// Preview
struct OnboardingPage_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPageSparklapse(
            model: OnboardingMainSparklapsePageModel(
                title: "Welcome to Lumenlane",
                description: "Track your fasts, stay motivated, and unlock premium features!",
                imageName: "purchaseview-hero"
            ),
            onContinue: {}
        )
    }
} 
