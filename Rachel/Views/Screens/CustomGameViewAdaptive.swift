//
//  CustomGameViewAdaptive.swift
//  Rachel
//
//  Created by Steve Hill on 07/08/2025.
//

import SwiftUI

struct CustomGameViewAdaptive: View {
    @Binding var isPresented: Bool
    let onStartGame: ([Player]) -> Void
    
    @State private var playerName = DeviceHelper.getPlayerName()
    @State private var numberOfAIPlayers = 3
    @State private var aiDifficulty: AISkillLevel = .medium
    @State private var mixedDifficulty = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private let aiNames = ["Alex", "Sam", "Jamie", "Casey", "Jordan", "Morgan", "Riley", "Quinn"]
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var body: some View {
        ZStack {
            BaizeBackground()
            
            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
    }
    
    var portraitLayout: some View {
        VStack(spacing: 24) {
            // Header
            headerView
                .padding(.top, 40)
            
            // Settings
            VStack(spacing: 20) {
                settingsContent
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Preview
            playerPreview
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Buttons
            buttonRow
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
        }
    }
    
    var landscapeLayout: some View {
        HStack(spacing: 0) {
            // Left side - settings
            ScrollView {
                VStack(spacing: 16) {
                    headerView
                        .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        settingsContent
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Right side - preview and buttons
            VStack {
                Spacer()
                
                playerPreview
                    .scaleEffect(0.9)
                
                Spacer()
                
                buttonRow
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.1))
        }
    }
    
    var headerView: some View {
        VStack(spacing: 8) {
            Text("Custom Game")
                .font(isLandscape ? .title : .largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if !isLandscape {
                Text("Set up your perfect game")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    @ViewBuilder
    var settingsContent: some View {
        // Player name
        VStack(alignment: .leading, spacing: 8) {
                Text("Your Name")
                    .font(.headline)
                    .foregroundColor(.white)
                
                TextField("Enter your name", text: $playerName)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            // Number of AI players
            VStack(alignment: .leading, spacing: 8) {
                Text("AI Opponents")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Picker("Opponents", selection: $numberOfAIPlayers) {
                    ForEach(1...7, id: \.self) { count in
                        Text("\(count) \(count == 1 ? "opponent" : "opponents")")
                            .tag(count)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Difficulty settings
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("AI Difficulty")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Toggle("Mixed", isOn: $mixedDifficulty)
                        .tint(.yellow)
                        .scaleEffect(0.9)
                }
                
                if !mixedDifficulty {
                    Picker("Difficulty", selection: $aiDifficulty) {
                        Text("Easy").tag(AISkillLevel.easy)
                        Text("Medium").tag(AISkillLevel.medium)
                        Text("Hard").tag(AISkillLevel.hard)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
    
    var playerPreview: some View {
        VStack(spacing: 12) {
            Text("Players")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Human player
                    PlayerPreviewBubble(
                        name: playerName.isEmpty ? "You" : playerName,
                        isHuman: true,
                        difficulty: nil
                    )
                    
                    // AI players
                    ForEach(0..<numberOfAIPlayers, id: \.self) { index in
                        PlayerPreviewBubble(
                            name: aiNames[index % aiNames.count],
                            isHuman: false,
                            difficulty: mixedDifficulty ? randomDifficulty(for: index) : aiDifficulty
                        )
                    }
                }
                .padding(.horizontal, 8)
            }
            .frame(height: 80)
        }
    }
    
    var buttonRow: some View {
        HStack(spacing: 16) {
            Button(action: { isPresented = false }) {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
            }
            
            Button(action: startGame) {
                Text("Start Game")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .cornerRadius(12)
            }
        }
    }
    
    private func randomDifficulty(for index: Int) -> AISkillLevel {
        // Ensure a good mix of difficulties
        let difficulties: [AISkillLevel] = [.easy, .medium, .hard]
        return difficulties[index % 3]
    }
    
    private func startGame() {
        var players: [Player] = []
        
        // Add human player
        let humanName = playerName.isEmpty ? "You" : playerName
        players.append(Player(id: "1", name: humanName))
        
        // Add AI players
        for i in 0..<numberOfAIPlayers {
            let aiName = aiNames[i % aiNames.count]
            let difficulty = mixedDifficulty ? randomDifficulty(for: i) : aiDifficulty
            players.append(Player(
                id: String(i + 2),
                name: aiName,
                isAI: true,
                aiSkillLevel: difficulty
            ))
        }
        
        onStartGame(players)
    }
}

struct PlayerPreviewBubble: View {
    let name: String
    let isHuman: Bool
    let difficulty: AISkillLevel?
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isHuman ? Color.blue : difficultyColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(name.prefix(1)))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            Text(name)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(1)
            
            if let difficulty = difficulty {
                Text(difficulty.shortName)
                    .font(.caption2)
                    .foregroundColor(difficultyColor.opacity(0.8))
            }
        }
        .frame(width: 70)
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        case .none:
            return .gray
        }
    }
}

extension AISkillLevel {
    var shortName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Med"
        case .hard: return "Hard"
        }
    }
}

#Preview("Portrait") {
    CustomGameViewAdaptive(isPresented: .constant(true)) { players in
        print("Starting game with \(players.count) players")
    }
}

#Preview("Landscape") {
    CustomGameViewAdaptive(isPresented: .constant(true)) { players in
        print("Starting game with \(players.count) players")
    }
}