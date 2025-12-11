import SwiftUI

struct ProtocolPickerView: View {
    @Binding var selectedProtocol: ZenFlowProtocol
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                List(ZenFlowProtocol.protocols) { sparklapseProtocol in
                    Button(action: {
                        selectedProtocol = sparklapseProtocol
                        dismiss()
                    }) {
                        HStack {
                            Text(sparklapseProtocol.name)
                                .foregroundColor(Color("PrimaryText"))
                            Spacer()
                            if sparklapseProtocol.id == selectedProtocol.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color("AccentText"))
                            }
                        }
                    }
                    .listRowBackground(Color("Background"))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Select Protocol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("Background"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

