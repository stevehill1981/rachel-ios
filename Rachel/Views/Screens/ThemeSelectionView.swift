//
//  ThemeSelectionView.swift
//  Rachel
//
//  Created by Assistant on 07/08/2025.
//

import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var iapManager = IAPManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedTheme: (any ThemeProtocol)?
    @State private var showingPurchaseError = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemedBackground()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(themeManager.allThemes, id: \.id) { theme in
                            ThemePreviewCard(
                                theme: theme,
                                isSelected: selectedTheme?.id == theme.id || (selectedTheme == nil && theme.id == themeManager.currentTheme.id),
                                isUnlocked: themeManager.isThemeUnlocked(theme),
                                onTap: {
                                    if themeManager.isThemeUnlocked(theme) {
                                        selectedTheme = theme
                                        themeManager.setTheme(theme)
                                    } else {
                                        // Future: Show purchase UI
                                        Task {
                                            await purchaseTheme(theme)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .alert("Purchase Failed", isPresented: $showingPurchaseError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(iapManager.errorMessage ?? "Unable to complete purchase")
        }
    }
    
    private func purchaseTheme(_ theme: any ThemeProtocol) async {
        // For now, just unlock it for testing
        // In production, this would handle the actual purchase
        print("Would purchase theme: \(theme.name)")
        
        // Temporary: unlock for testing
        // Remove this when IAP is implemented
        themeManager.unlockTheme(withId: theme.id)
        selectedTheme = theme
        themeManager.setTheme(theme)
    }
}

struct ThemePreviewCard: View {
    let theme: any ThemeProtocol
    let isSelected: Bool
    let isUnlocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Mini preview
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        theme.backgroundGradient ?? LinearGradient(
                            colors: [theme.backgroundColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                
                // Mini cards
                HStack(spacing: -20) {
                    ForEach(0..<3) { index in
                        ThemedCardBack(width: 40, height: 56)
                            .environment(\.theme, theme)
                            .rotationEffect(.degrees(Double(index - 1) * 10))
                    }
                }
                
                if !isUnlocked {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.7))
                    
                    VStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                        Text("Premium")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                }
            }
            
            // Theme name
            Text(theme.name)
                .font(.headline)
                .foregroundColor(.white)
            
            // Selection indicator
            if isSelected && isUnlocked {
                Label("Selected", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(theme.accentColor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isSelected ? theme.accentColor : Color.clear,
                            lineWidth: 2
                        )
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    ThemeSelectionView()
        .themed()
}