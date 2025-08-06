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
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.1, green: 0.2, blue: 0.4), Color(red: 0.05, green: 0.1, blue: 0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Pattern background
                    ZStack {
                        // Diamond pattern
                        ForEach(0..<5) { row in
                            ForEach(0..<3) { col in
                                DiamondShape()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    .frame(width: geometry.size.width * 0.25, height: geometry.size.height * 0.15)
                                    .position(
                                        x: geometry.size.width * (0.25 + CGFloat(col) * 0.25),
                                        y: geometry.size.height * (0.1 + CGFloat(row) * 0.2)
                                    )
                            }
                        }
                        
                        // Center emblem
                        Circle()
                            .fill(Color(red: 0.15, green: 0.25, blue: 0.45))
                            .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                            .overlay(
                                VStack(spacing: 2) {
                                    Text("R")
                                        .font(.system(size: geometry.size.width * 0.25, weight: .bold, design: .serif))
                                        .foregroundColor(.white.opacity(0.9))
                                    Rectangle()
                                        .fill(Color.white.opacity(0.5))
                                        .frame(width: geometry.size.width * 0.3, height: 1)
                                    HStack(spacing: 4) {
                                        ForEach(["♠", "♥", "♦", "♣"], id: \.self) { symbol in
                                            Text(symbol)
                                                .font(.system(size: geometry.size.width * 0.08))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                }
                            )
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                )
                .overlay(
                    // Border
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
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

#Preview {
    ZStack {
        BaizeBackground()
        CardBackView()
            .frame(height: 150)
            .padding()
    }
}