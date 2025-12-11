import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var zenFlowManager: ZenFlowManager
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                FocusView()
                    .tag(0)
                
                HistoryView()
                    .tag(1)
                
                SettingsView()
                    .tag(2)
                
                ProgressView()
                    .tag(3)
            }
            .background(Color(red: 0x2C/255, green: 0x39/255, blue: 0x51/255))
            .accentColor(Color("ButtonColor"))
            .onAppear {
                // Устанавливаем цвет для UITabBar
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(red: 0x2C/255, green: 0x39/255, blue: 0x51/255, alpha: 1.0)
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                ForEach(0..<4) { index in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            ZStack {
                                if selectedTab == index {
                                    Capsule()
                                        .fill(Color("ButtonColor"))
                                        .frame(width: 60, height: 40)
                                }
                                Image(tabIcon(for: index))
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedTab == index ? .white : .gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(red: 0x55/255, green: 0x6A/255, blue: 0x7B/255))
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(red: 0x2C/255, green: 0x39/255, blue: 0x51/255).ignoresSafeArea(.all, edges: .bottom))
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "bb_item_one"
        case 1: return "bb_item_two"
        case 2: return "bb_item_three"
        case 3: return "bb_item_four"
        default: return ""
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "ZenFlow"
        case 1: return "History"
        case 2: return "Progress"
        case 3: return "Settings"
        default: return ""
        }
    }
}

