//
//  StartScreenView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct StartScreenView: View {
    let onQuickPlay: () -> Void
    let onCustomGame: () -> Void
    
    @State private var showRules = false
    
    var body: some View {
        ZStack {
            // Background
            BaizeBackground()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Title
                VStack(spacing: 8) {
                    Text("Rachel")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    
                    Text("The strategic card game that's been bringing friends and families together for over 30 years")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer(minLength: 10)
                
                // Decorative animated cards - 3D circle
                DecorativeCardsView(style: .circle3D)
                    .frame(height: 200)
                    .padding(.vertical, 10)
                
                Spacer(minLength: 10)
                
                // Game mode buttons
                VStack(spacing: 20) {
                    // Quick Play button
                    Button(action: onQuickPlay) {
                        VStack(spacing: 4) {
                            Text("Quick Play")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("4 Players • 3 AI Opponents")
                                .font(.caption)
                                .opacity(0.8)
                        }
                        .foregroundColor(.white)
                        .frame(width: 220, height: 70)
                        .background(Color.blue)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    }
                    .accessibilityLabel("Quick play with 3 AI opponents")
                    
                    // Custom Game button
                    Button(action: onCustomGame) {
                        VStack(spacing: 4) {
                            Text("Custom Game")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Choose players & difficulty")
                                .font(.caption)
                                .opacity(0.8)
                        }
                        .foregroundColor(.white)
                        .frame(width: 220, height: 70)
                        .background(Color.green)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    }
                    .accessibilityLabel("Create custom game")
                    
                    // Rules button
                    Button(action: { showRules = true }) {
                        Text("How to Play")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 220, height: 45)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("View game rules")
                }
                
                Spacer(minLength: 20)
                
                // Credits
                VStack(spacing: 2) {
                    Text("Created by Steve Hill")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    Text("Built with ❤️ and SwiftUI")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showRules) {
            RulesView()
        }
    }
}

#Preview {
    StartScreenView(
        onQuickPlay: {
            print("Quick play tapped")
        },
        onCustomGame: {
            print("Custom game tapped")
        }
    )
}