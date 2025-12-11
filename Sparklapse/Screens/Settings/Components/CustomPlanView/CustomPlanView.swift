import SwiftUI
import SwiftData
import StoreKit
import UserNotifications

struct CustomPlanView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var zenFlowManager: ZenFlowManager
    @State private var fastingHours: Double = 16
    @State private var eatingHours: Double = 8
    @State private var showError = false
    
    private let hoursRange = Array(1...23)
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // ZenFlow Hours Picker
                VStack(alignment: .leading, spacing: 15) {
                    Text("ZenFlow Hours")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Picker("ZenFlow Hours", selection: $fastingHours) {
                        ForEach(hoursRange, id: \.self) { hour in
                            Text("\(hour)h").tag(Double(hour))
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .clipped()
                    
                    Text("\(Int(fastingHours)) hours")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.1))
                )
                
                // Eating Hours Picker
                VStack(alignment: .leading, spacing: 15) {
                    Text("Phone Free Hours")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Picker("Phone Hours", selection: $eatingHours) {
                        ForEach(hoursRange, id: \.self) { hour in
                            Text("\(hour)h").tag(Double(hour))
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .clipped()
                    
                    Text("\(Int(eatingHours)) hours")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.1))
                )
                
                // Total Hours Display
                VStack(spacing: 10) {
                    Text("Total Hours")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(Int(fastingHours + eatingHours))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(fastingHours + eatingHours == 24 ? .green : .red)
                    
                    Text(fastingHours + eatingHours == 24 ? "Perfect! 24 hours" : "Must equal 24 hours")
                        .font(.subheadline)
                        .foregroundColor(fastingHours + eatingHours == 24 ? .green : .red)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(fastingHours + eatingHours == 24 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                )
                
                // Save Button
                Button("SAVE") {
                    saveCustomPlan()
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
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
                .padding(.horizontal)
                .disabled(fastingHours + eatingHours != 24)
                .opacity(fastingHours + eatingHours == 24 ? 1.0 : 0.5)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Custom 24h Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("Background"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveCustomPlan()
                }
                .disabled(fastingHours + eatingHours != 24)
                .foregroundColor(.white)
            }
        }
        .alert("Invalid Plan", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Total hours must equal 24")
                .foregroundColor(.white)
        }
    }
    
    private func saveCustomPlan() {
        if fastingHours + eatingHours == 24 {
            let customProtocol = ZenFlowProtocol(
                name: "\(Int(fastingHours)):\(Int(eatingHours))",
                fastingHours: fastingHours,
                eatingHours: eatingHours,
                color: Color(red: 0.7, green: 0.6, blue: 0.9) // Lavender
            )
            zenFlowManager.availableProtocols.append(customProtocol)
            zenFlowManager.selectedProtocol = customProtocol
            dismiss()
        } else {
            showError = true
        }
    }
}
