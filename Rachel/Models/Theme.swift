//
//  Theme.swift
//  Rachel
//
//  Created by Assistant on 07/08/2025.
//

import SwiftUI

// MARK: - Theme Protocol
protocol ThemeProtocol {
    var id: String { get }
    var name: String { get }
    var isPremium: Bool { get }
    
    // Table/Background
    var backgroundColor: Color { get }
    var backgroundGradient: LinearGradient? { get }
    var baizeTexture: String? { get }
    
    // Card styling
    var cardBackColor: Color { get }
    var cardBackPattern: String? { get }
    var cardBackGradient: LinearGradient? { get }
    
    // UI Elements
    var primaryTextColor: Color { get }
    var secondaryTextColor: Color { get }
    var accentColor: Color { get }
    var buttonColor: Color { get }
}

// MARK: - Built-in Themes
struct ClassicTheme: ThemeProtocol {
    let id = "classic"
    let name = "Classic"
    let isPremium = false
    
    let backgroundColor = Color(red: 0.0, green: 0.4, blue: 0.2)
    let backgroundGradient: LinearGradient? = nil
    let baizeTexture: String? = nil
    
    let cardBackColor = Color.blue
    let cardBackPattern: String? = nil
    let cardBackGradient: LinearGradient? = LinearGradient(
        colors: [Color.blue, Color.blue.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    let primaryTextColor = Color.white
    let secondaryTextColor = Color.white.opacity(0.8)
    let accentColor = Color.yellow
    let buttonColor = Color.green
}

struct MidnightTheme: ThemeProtocol {
    let id = "midnight"
    let name = "Midnight"
    let isPremium = true
    
    let backgroundColor = Color.black
    var backgroundGradient: LinearGradient? {
        LinearGradient(
            colors: [Color.black, Color(white: 0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    let baizeTexture: String? = nil
    
    let cardBackColor = Color.purple
    let cardBackPattern: String? = nil
    var cardBackGradient: LinearGradient? {
        LinearGradient(
            colors: [Color.purple, Color.indigo],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    let primaryTextColor = Color.white
    let secondaryTextColor = Color.white.opacity(0.7)
    let accentColor = Color.cyan
    let buttonColor = Color.purple
}

struct OceanTheme: ThemeProtocol {
    let id = "ocean"
    let name = "Ocean"
    let isPremium = true
    
    let backgroundColor = Color(red: 0.0, green: 0.3, blue: 0.5)
    var backgroundGradient: LinearGradient? {
        LinearGradient(
            colors: [
                Color(red: 0.0, green: 0.2, blue: 0.4),
                Color(red: 0.0, green: 0.4, blue: 0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    let baizeTexture: String? = nil
    
    let cardBackColor = Color.teal
    let cardBackPattern: String? = nil
    var cardBackGradient: LinearGradient? {
        LinearGradient(
            colors: [Color.teal, Color.blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    let primaryTextColor = Color.white
    let secondaryTextColor = Color.white.opacity(0.8)
    let accentColor = Color.orange
    let buttonColor = Color.teal
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: any ThemeProtocol
    @Published var unlockedThemeIds: Set<String>
    
    let allThemes: [any ThemeProtocol] = [
        ClassicTheme(),
        MidnightTheme(),
        OceanTheme()
    ]
    
    private let currentThemeKey = "currentThemeId"
    private let unlockedThemesKey = "unlockedThemeIds"
    
    private init() {
        // Load saved theme preference
        let savedThemeId = UserDefaults.standard.string(forKey: currentThemeKey) ?? "classic"
        
        // Load unlocked themes
        if let unlockedData = UserDefaults.standard.data(forKey: unlockedThemesKey),
           let unlocked = try? JSONDecoder().decode(Set<String>.self, from: unlockedData) {
            self.unlockedThemeIds = unlocked
        } else {
            // Start with only classic unlocked
            self.unlockedThemeIds = ["classic"]
        }
        
        // Set current theme
        self.currentTheme = allThemes.first { $0.id == savedThemeId } ?? ClassicTheme()
    }
    
    func setTheme(_ theme: any ThemeProtocol) {
        guard !theme.isPremium || unlockedThemeIds.contains(theme.id) else { return }
        
        currentTheme = theme
        UserDefaults.standard.set(theme.id, forKey: currentThemeKey)
    }
    
    func unlockTheme(withId id: String) {
        unlockedThemeIds.insert(id)
        saveUnlockedThemes()
    }
    
    func isThemeUnlocked(_ theme: any ThemeProtocol) -> Bool {
        !theme.isPremium || unlockedThemeIds.contains(theme.id)
    }
    
    private func saveUnlockedThemes() {
        if let data = try? JSONEncoder().encode(unlockedThemeIds) {
            UserDefaults.standard.set(data, forKey: unlockedThemesKey)
        }
    }
    
    // For future IAP integration
    func unlockAllThemes() {
        allThemes.forEach { theme in
            unlockedThemeIds.insert(theme.id)
        }
        saveUnlockedThemes()
    }
}

// MARK: - Theme Environment Key
private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: any ThemeProtocol = ClassicTheme()
}

extension EnvironmentValues {
    var theme: any ThemeProtocol {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Extensions
extension View {
    func themed() -> some View {
        self.environmentObject(ThemeManager.shared)
            .environment(\.theme, ThemeManager.shared.currentTheme)
    }
}