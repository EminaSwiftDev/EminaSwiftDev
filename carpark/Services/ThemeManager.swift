//
//  ThemeManager.swift
//  carpark
//

import SwiftUI
import Combine

enum VisualStyle: String, Codable, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    var schemePreference: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
    
    var representativeIcon: String {
        let iconMap: [VisualStyle: String] = [
            .light: "sun.max.fill",
            .dark: "moon.fill",
            .system: "circle.lefthalf.filled"
        ]
        return iconMap[self] ?? "circle.lefthalf.filled"
    }
}

class AppearanceController: ObservableObject {
    static let instance = AppearanceController()
    
    @Published var activeStyle: VisualStyle {
        didSet {
            saveStylePreference()
        }
    }
    
    private let styleStorageKey = "app_theme"
    
    init() {
        if let storedStyle = UserDefaults.standard.string(forKey: styleStorageKey),
           let style = VisualStyle(rawValue: storedStyle) {
            activeStyle = style
        } else {
            activeStyle = .system
        }
    }
    
    private func saveStylePreference() {
        UserDefaults.standard.set(activeStyle.rawValue, forKey: styleStorageKey)
    }
}

struct ColorPalette {
    static func backgroundCard(scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(uiColor: .secondarySystemGroupedBackground) : .white
    }
    
    static func backgroundMain(scheme: ColorScheme) -> Color {
        Color(uiColor: .systemGroupedBackground)
    }
    
    static func backgroundSecondary(scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(uiColor: .tertiarySystemGroupedBackground) : Color.gray.opacity(0.1)
    }
    
    static func backgroundRow(scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(uiColor: .secondarySystemGroupedBackground) : .white
    }
}
