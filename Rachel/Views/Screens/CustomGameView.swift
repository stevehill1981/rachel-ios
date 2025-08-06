//
//  CustomGameView.swift
//  Rachel
//
//  Created by Steve Hill on 06/08/2025.
//

import SwiftUI

struct CustomGameView: View {
    @Binding var isPresented: Bool
    let onStartGame: ([Player]) -> Void
    
    @State private var playerName = DeviceHelper.getPlayerName()
    @State private var numberOfAIPlayers = 3
    @State private var aiDifficulty: AISkillLevel = .medium
    @State private var mixedDifficulty = false
    
    private let aiNames = ["Alex", "Sam", "Jamie", "Casey", "Jordan", "Morgan", "Riley", "Quinn"]
    
    var body: some View {
        ZStack {
            BaizeBackground()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Custom Game")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Set up your perfect game")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 40)
                
                // Settings
                VStack(spacing: 20) {
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
                        Text("Number of Opponents")
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
                    
                    // AI Difficulty
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("AI Difficulty")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Toggle("Mixed", isOn: $mixedDifficulty)
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                                .scaleEffect(0.8)
                        }
                        
                        if !mixedDifficulty {
                            Picker("Difficulty", selection: $aiDifficulty) {
                                ForEach([AISkillLevel.easy, .medium, .hard], id: \.self) { level in
                                    Text(level.name).tag(level)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        } else {
                            Text("Each opponent will have a random difficulty")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    Button(action: startGame) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Game")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green)
                        )
                    }
                    
                    Button(action: { isPresented = false }) {
                        Text("Cancel")
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
    }
    
    private func startGame() {
        var players: [Player] = []
        
        // Add human player
        let humanName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        players.append(Player(id: "1", name: humanName.isEmpty ? "Player" : humanName))
        
        // Add AI players
        let availableNames = aiNames.shuffled()
        let difficulties: [AISkillLevel] = mixedDifficulty ? 
            [.easy, .medium, .hard].shuffled() : 
            Array(repeating: aiDifficulty, count: numberOfAIPlayers)
        
        for i in 0..<numberOfAIPlayers {
            let name = i < availableNames.count ? availableNames[i] : "AI \(i + 1)"
            let difficulty = i < difficulties.count ? difficulties[i] : .medium
            players.append(Player(
                id: "\(i + 2)",
                name: name,
                isAI: true,
                aiSkillLevel: difficulty
            ))
        }
        
        onStartGame(players)
        isPresented = false
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.white)
            .accentColor(.green)
    }
}

#Preview {
    CustomGameView(isPresented: .constant(true)) { players in
        print("Starting game with \(players.count) players")
    }
}