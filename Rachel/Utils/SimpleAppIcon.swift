//
//  SimpleAppIcon.swift
//  Rachel
//
//  Created by Steve Hill on 07/08/2025.
//

import SwiftUI

struct SimpleAppIcon: View {
    var body: some View {
        ZStack {
            // Baize green background
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.0, green: 0.5, blue: 0.25),
                            Color(red: 0.0, green: 0.3, blue: 0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Simple "R" logo with card suit symbols
            VStack(spacing: 40) {
                // Card suits in corners
                HStack {
                    Text("♠")
                        .font(.system(size: 120))
                        .foregroundColor(.black.opacity(0.3))
                    Spacer()
                    Text("♥")
                        .font(.system(size: 120))
                        .foregroundColor(.red.opacity(0.3))
                }
                .padding(60)
                
                Spacer()
                
                // Large "R" in center
                Text("R")
                    .font(.system(size: 400, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Spacer()
                
                // Bottom suits
                HStack {
                    Text("♦")
                        .font(.system(size: 120))
                        .foregroundColor(.red.opacity(0.3))
                    Spacer()
                    Text("♣")
                        .font(.system(size: 120))
                        .foregroundColor(.black.opacity(0.3))
                }
                .padding(60)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

#Preview {
    SimpleAppIcon()
        .previewLayout(.fixed(width: 1024, height: 1024))
}