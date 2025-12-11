import SwiftUI
import SwiftData
import StoreKit
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var zenFlowManager: ZenFlowManager
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showingCustomPlan24 = false
    @State private var showingCustomPlan48 = false
    @State private var showingCustomPlan72 = false
    
    private let gridLayout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private var isCustomProtocol: Bool {
        !ZenFlowProtocol.protocols.contains(where: { $0.id == zenFlowManager.selectedProtocol.id })
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Fasting Plans Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phone-Free Plans")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: gridLayout, spacing: 16) {
                                ForEach(ZenFlowProtocol.protocols) { zenFlowProtocol in
                                    Button(action: {
                                        zenFlowManager.selectedProtocol = zenFlowProtocol
                                    }) {
                                        VStack(spacing: 8) {
                                            HStack(spacing: 20) {
                                                Text(formatHours(zenFlowProtocol.fastingHours))
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                
                                                Image(systemName: "clock")
                                                    .font(.title2)
                                                    .foregroundColor(.white)
                                                
                                                Text(formatHours(zenFlowProtocol.eatingHours))
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Text("phone-free : open")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(zenFlowManager.selectedProtocol.id == zenFlowProtocol.id ?
                                                      zenFlowProtocol.color.opacity(0.3) :
                                                        zenFlowProtocol.color.opacity(0.15))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                // Custom Plan 24h Button
                                Button(action: {
                                    showingCustomPlan24 = true
                                }) {
                                    CustomPlanButtonContent(hours: 24, isSelected: isCustomProtocol && zenFlowManager.selectedProtocol.fastingHours + zenFlowManager.selectedProtocol.eatingHours == 24)
                                }
                                .buttonStyle(.plain)
                                
                                // Custom Plan 48h Button
                                Button(action: {
                                    showingCustomPlan48 = true
                                }) {
                                    CustomPlanButtonContent(hours: 48, isSelected: isCustomProtocol && zenFlowManager.selectedProtocol.fastingHours + zenFlowManager.selectedProtocol.eatingHours == 48)
                                }
                                .buttonStyle(.plain)
                                
                                // Custom Plan 72h Button
                                Button(action: {
                                    showingCustomPlan72 = true
                                }) {
                                    CustomPlanButtonContent(hours: 72, isSelected: isCustomProtocol && zenFlowManager.selectedProtocol.fastingHours + zenFlowManager.selectedProtocol.eatingHours == 72)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                        }
                        
                        // Notification Permission Section
                        NotificationSettingsSection()
                        
                    }
                    .padding(.vertical)
                    .padding(.bottom, 60)
                }
                // .navigationTitle("Settings")
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
                                
                                Image("bb_item_three")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                
                            }
                            
                            Text("Settings")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color("Background"), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .sheet(isPresented: $showingCustomPlan24) {
                    CustomPlanView()
                }
                .sheet(isPresented: $showingCustomPlan48) {
                    CustomPlan48View()
                }
                .sheet(isPresented: $showingCustomPlan72) {
                    CustomPlan72View()
                }
                .alert("Error", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                    
                }
            }
        }
    }
    
    private func formatHours(_ hours: Double) -> String {
        return "\(Int(hours))"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(ZenFlowManager(modelContext: try! ModelContainer(for: ZenFlowSession.self).mainContext))
    }
}
