//
//  StartScreenAdaptive.swift
//  Rachel
//
//  Created by Steve Hill on 07/08/2025.
//

import SwiftUI

struct StartScreenAdaptive: View {
    let onQuickPlay: () -> Void
    let onCustomGame: () -> Void
    let onMultiplayer: () -> Void
    
    @State private var showRules = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ZStack {
            // Background
            BaizeBackground()
            
            if isLandscape && !isIPad {
                // Landscape iPhone layout
                landscapeLayout
            } else {
                // Portrait or iPad layout
                portraitLayout
            }
        }
        .sheet(isPresented: $showRules) {
            RulesView()
        }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
    }
    
    var portraitLayout: some View {
        VStack(spacing: isIPad ? 40 : 20) {
            Spacer()
            
            // Title
            VStack(spacing: 8) {
                Text("Rachel")
                    .font(.system(size: isIPad ? 80 : 50, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                Text("The strategic card game for friends and family")
                    .font(isIPad ? .body : .subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
            }
            
            // Decorative cards
            DecorativeCardsView(style: .circle3D)
                .frame(height: isIPad ? 300 : 200)
                .padding(.vertical, isIPad ? 20 : 10)
            
            // Buttons
            buttonsView
            
            Spacer()
            
            // Credits
            creditsView
                .padding(.bottom, isIPad ? 30 : 10)
        }
        .padding(.horizontal)
    }
    
    var landscapeLayout: some View {
        HStack(spacing: 40) {
            // Left side - Title and cards
            VStack(spacing: 20) {
                Text("Rachel")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                DecorativeCardsView(style: .circle3D)
                    .frame(maxHeight: 150)
            }
            .frame(maxWidth: .infinity)
            
            // Right side - Buttons
            VStack(spacing: 15) {
                buttonsView
                creditsView
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
    
    var buttonsView: some View {
        VStack(spacing: isIPad ? 25 : 15) {
            // Quick Play button
            Button(action: onQuickPlay) {
                VStack(spacing: 4) {
                    Text("Quick Play")
                        .font(isIPad ? .title : .title2)
                        .fontWeight(.bold)
                    Text("4 Players • 3 AI Opponents")
                        .font(isIPad ? .callout : .caption)
                        .opacity(0.8)
                }
                .foregroundColor(.white)
                .frame(maxWidth: isIPad ? 300 : 220)
                .padding(.vertical, isIPad ? 20 : 15)
                .background(Color.blue)
                .cornerRadius(20)
                .shadow(radius: 5)
            }
            
            // Custom Game button
            Button(action: onCustomGame) {
                VStack(spacing: 4) {
                    Text("Custom Game")
                        .font(isIPad ? .title : .title2)
                        .fontWeight(.bold)
                    Text("Choose players & difficulty")
                        .font(isIPad ? .callout : .caption)
                        .opacity(0.8)
                }
                .foregroundColor(.white)
                .frame(maxWidth: isIPad ? 300 : 220)
                .padding(.vertical, isIPad ? 20 : 15)
                .background(Color.green)
                .cornerRadius(20)
                .shadow(radius: 5)
            }
            
            // Multiplayer button
            Button(action: onMultiplayer) {
                VStack(spacing: 4) {
                    Text("Multiplayer")
                        .font(isIPad ? .title : .title2)
                        .fontWeight(.bold)
                    Text("Host or join a game")
                        .font(isIPad ? .callout : .caption)
                        .opacity(0.8)
                }
                .foregroundColor(.white)
                .frame(maxWidth: isIPad ? 300 : 220)
                .padding(.vertical, isIPad ? 20 : 15)
                .background(Color.purple)
                .cornerRadius(20)
                .shadow(radius: 5)
            }
            
            // Rules button
            Button(action: { showRules = true }) {
                Text("How to Play")
                    .font(isIPad ? .title3 : .headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: isIPad ? 300 : 220)
                    .padding(.vertical, isIPad ? 15 : 10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
            }
        }
    }
    
    var creditsView: some View {
        VStack(spacing: 2) {
            Text("Created by Steve Hill")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
            Text("Built with ❤️ and SwiftUI")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

#Preview("iPhone Portrait") {
    StartScreenAdaptive(
        onQuickPlay: { print("Quick play") },
        onCustomGame: { print("Custom game") },
        onMultiplayer: { print("Multiplayer") }
    )
}

#Preview("iPhone Landscape", traits: .landscapeLeft) {
    StartScreenAdaptive(
        onQuickPlay: { print("Quick play") },
        onCustomGame: { print("Custom game") },
        onMultiplayer: { print("Multiplayer") }
    )
}

#Preview("iPad") {
    StartScreenAdaptive(
        onQuickPlay: { print("Quick play") },
        onCustomGame: { print("Custom game") },
        onMultiplayer: { print("Multiplayer") }
    )
}