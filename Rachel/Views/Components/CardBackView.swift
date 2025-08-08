//
//  CardBackView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct CardBackView: View {
    var body: some View {
        GeometryReader { geometry in
            ThemedCardBack(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
        .aspectRatio(5/7, contentMode: .fit)
    }
}

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        
        return path
    }
}

#Preview("Theme Comparison") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            CardBackView()
                .frame(height: 150)
                .environment(\.theme, ClassicTheme())
            
            CardBackView()
                .frame(height: 150)
                .environment(\.theme, MidnightTheme())
            
            CardBackView()
                .frame(height: 150)
                .environment(\.theme, OceanTheme())
        }
        .padding()
    }
    .background(Color.gray)
}