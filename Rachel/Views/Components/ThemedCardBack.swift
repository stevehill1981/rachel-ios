//
//  ThemedCardBack.swift
//  Rachel
//
//  Created by Assistant on 07/08/2025.
//

import SwiftUI

struct ThemedCardBack: View {
    @Environment(\.theme) var theme
    let width: CGFloat
    let height: CGFloat
    
    init(width: CGFloat = 70, height: CGFloat = 100) {
        self.width = width
        self.height = height
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: width * 0.1)
                .fill(Color.white)
                .frame(width: width, height: height)
            
            RoundedRectangle(cornerRadius: width * 0.1)
                .fill(
                    theme.cardBackGradient ?? LinearGradient(
                        colors: [theme.cardBackColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: width - 4, height: height - 4)
            
            // Pattern overlay
            if let pattern = theme.cardBackPattern {
                Image(pattern)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width - 8, height: height - 8)
                    .clipShape(RoundedRectangle(cornerRadius: width * 0.08))
                    .opacity(0.3)
            } else {
                // Default pattern
                GeometryReader { geometry in
                    Path { path in
                        let spacing = width * 0.15
                        
                        // Create diagonal lines pattern
                        for i in stride(from: -height, to: width + height, by: spacing) {
                            path.move(to: CGPoint(x: i, y: 0))
                            path.addLine(to: CGPoint(x: i + height, y: height))
                        }
                    }
                    .stroke(Color.white.opacity(0.2), lineWidth: width * 0.02)
                    .clipShape(RoundedRectangle(cornerRadius: width * 0.08))
                }
                .frame(width: width - 8, height: height - 8)
            }
            
            // Center logo/design
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: width * 0.4, height: width * 0.4)
            
            Text("R")
                .font(.system(size: width * 0.25, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.3))
        }
        .shadow(radius: 2)
    }
}

#Preview("Theme Comparison") {
    VStack(spacing: 20) {
        ThemedCardBack()
            .environment(\.theme, ClassicTheme())
        
        ThemedCardBack()
            .environment(\.theme, MidnightTheme())
        
        ThemedCardBack()
            .environment(\.theme, OceanTheme())
    }
    .padding()
    .background(Color.gray)
}