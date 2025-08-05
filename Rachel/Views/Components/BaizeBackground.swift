//
//  BaizeBackground.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct BaizeBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.0, green: 0.3, blue: 0.1),
                Color(red: 0.0, green: 0.4, blue: 0.15)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(
            // Subtle texture overlay
            LinearGradient(
                colors: [
                    Color.black.opacity(0.1),
                    Color.clear,
                    Color.black.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.multiply)
        )
    }
}

#Preview {
    BaizeBackground()
}