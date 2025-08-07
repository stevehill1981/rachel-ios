//
//  MultiplayerLobbyView.swift
//  Rachel
//
//  Created by Steve Hill on 07/08/2025.
//

import SwiftUI

struct MultiplayerLobbyView: View {
    @Binding var isPresented: Bool
    let onStartGame: ([Player]) -> Void
    
    @State private var lobbyCode = generateLobbyCode()
    @State private var playerName = DeviceHelper.getPlayerName()
    @State private var connectedPlayers: [LobbyPlayer] = []
    @State private var isHost = true
    @State private var showJoinView = false
    @State private var joinCode = ""
    @State private var showCopiedToast = false
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    struct LobbyPlayer: Identifiable {
        let id = UUID()
        let name: String
        let isHost: Bool
        let isReady: Bool
        var aiDifficulty: AISkillLevel?
    }
    
    var body: some View {
        ZStack {
            BaizeBackground()
            
            if showJoinView {
                joinGameView
            } else {
                lobbyView
            }
            
            // Copied toast
            if showCopiedToast {
                VStack {
                    Spacer()
                    
                    Text("Code Copied!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(25)
                        .shadow(radius: 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .padding(.bottom, 50)
                .animation(.easeInOut, value: showCopiedToast)
            }
        }
    }
    
    var lobbyView: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            if isLandscape {
                landscapeLobbyContent
            } else {
                portraitLobbyContent
            }
        }
    }
    
    var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: { isPresented = false }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                }
                
                Spacer()
                
                if !isHost {
                    Button("Leave") {
                        // Leave lobby logic
                        isPresented = false
                    }
                    .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            
            Text(isHost ? "Host Game" : "Game Lobby")
                .font(isLandscape ? .title2 : .largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if isHost {
                // Lobby code display
                VStack(spacing: 4) {
                    Text("Game Code")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 12) {
                        Text(lobbyCode)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.yellow)
                        
                        Button(action: copyCode) {
                            Image(systemName: "doc.on.doc")
                                .font(.title3)
                                .foregroundColor(.yellow)
                        }
                        
                        Button(action: shareCode) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.yellow.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(.vertical, 20)
        .background(Color.black.opacity(0.2))
    }
    
    var portraitLobbyContent: some View {
        VStack(spacing: 20) {
            // Connected players
            VStack(alignment: .leading, spacing: 12) {
                Text("Players (\(connectedPlayers.count + 1)/8)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ScrollView {
                    VStack(spacing: 8) {
                        // Host (you)
                        PlayerRow(
                            name: playerName.isEmpty ? "You" : playerName,
                            isHost: true,
                            isReady: true,
                            isYou: true
                        )
                        
                        // Connected players
                        ForEach(connectedPlayers) { player in
                            if player.name.contains("AI") {
                                AIPlayerRow(
                                    player: player,
                                    onDifficultyChange: { newDifficulty in
                                        updateAIDifficulty(playerId: player.id, difficulty: newDifficulty)
                                    }
                                )
                            } else {
                                PlayerRow(
                                    name: player.name,
                                    isHost: player.isHost,
                                    isReady: player.isReady,
                                    isYou: false
                                )
                            }
                        }
                        
                        // Empty slots
                        ForEach(0..<(7 - connectedPlayers.count), id: \.self) { _ in
                            EmptyPlayerSlot()
                        }
                    }
                }
                .frame(maxHeight: 400)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 16) {
                if isHost {
                    Button(action: startGame) {
                        Text("Start Game")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(connectedPlayers.isEmpty ? Color.gray : Color.green)
                            .cornerRadius(12)
                    }
                    .disabled(connectedPlayers.isEmpty)
                    
                    Button(action: addAIPlayer) {
                        Label("Add AI Player", systemImage: "plus.circle")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(12)
                    }
                    .disabled(connectedPlayers.count >= 7)
                }
                
                if !isHost {
                    Button(action: toggleReady) {
                        Text("Ready")
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
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    var landscapeLobbyContent: some View {
        HStack(spacing: 0) {
            // Players list
            VStack(alignment: .leading, spacing: 12) {
                Text("Players (\(connectedPlayers.count + 1)/8)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 8) {
                        // Host (you)
                        PlayerRow(
                            name: playerName.isEmpty ? "You" : playerName,
                            isHost: true,
                            isReady: true,
                            isYou: true
                        )
                        
                        // Connected players
                        ForEach(connectedPlayers) { player in
                            if player.name.contains("AI") {
                                AIPlayerRow(
                                    player: player,
                                    onDifficultyChange: { newDifficulty in
                                        updateAIDifficulty(playerId: player.id, difficulty: newDifficulty)
                                    }
                                )
                            } else {
                                PlayerRow(
                                    name: player.name,
                                    isHost: player.isHost,
                                    isReady: player.isReady,
                                    isYou: false
                                )
                            }
                        }
                        
                        // Empty slots
                        ForEach(0..<(7 - connectedPlayers.count), id: \.self) { _ in
                            EmptyPlayerSlot()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Actions
            VStack(spacing: 16) {
                Spacer()
                
                if isHost {
                    Button(action: startGame) {
                        Text("Start Game")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 200)
                            .padding(.vertical, 16)
                            .background(connectedPlayers.isEmpty ? Color.gray : Color.green)
                            .cornerRadius(12)
                    }
                    .disabled(connectedPlayers.isEmpty)
                    
                    Button(action: addAIPlayer) {
                        Label("Add AI Player", systemImage: "plus.circle")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200)
                            .padding(.vertical, 16)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(12)
                    }
                    .disabled(connectedPlayers.count >= 7)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
    
    var joinGameView: some View {
        VStack(spacing: 24) {
            // Back button
            HStack {
                Button(action: { showJoinView = false }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 32) {
                Text("Join Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    Text("Enter Game Code")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    TextField("", text: $joinCode)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .textFieldStyle(MultiplayerTextFieldStyle())
                        .frame(width: 200)
                        .onChange(of: joinCode) { oldValue, newValue in
                            joinCode = String(newValue.prefix(6)).uppercased()
                        }
                }
                
                Button(action: joinGame) {
                    Text("Join")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding(.vertical, 16)
                        .background(joinCode.count == 6 ? Color.green : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(joinCode.count != 6)
            }
            
            Spacer()
            
            // Host/Join toggle
            VStack(spacing: 8) {
                Text("Want to host instead?")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Button("Host New Game") {
                    showJoinView = false
                    isHost = true
                }
                .foregroundColor(.yellow)
            }
            .padding(.bottom, 40)
        }
    }
    
    // Actions
    private func copyCode() {
        UIPasteboard.general.string = lobbyCode
        showCopiedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopiedToast = false
        }
    }
    
    private func startGame() {
        var players: [Player] = []
        players.append(Player(id: "1", name: playerName.isEmpty ? "You" : playerName))
        
        for (index, lobbyPlayer) in connectedPlayers.enumerated() {
            if lobbyPlayer.name.contains("AI") {
                players.append(Player(
                    id: String(index + 2),
                    name: lobbyPlayer.name,
                    isAI: true,
                    aiSkillLevel: lobbyPlayer.aiDifficulty ?? .medium
                ))
            } else {
                players.append(Player(
                    id: String(index + 2),
                    name: lobbyPlayer.name
                ))
            }
        }
        
        onStartGame(players)
    }
    
    private func addAIPlayer() {
        let aiNames = ["Alex (AI)", "Sam (AI)", "Jamie (AI)", "Casey (AI)"]
        let aiName = aiNames[connectedPlayers.filter { $0.name.contains("AI") }.count % aiNames.count]
        connectedPlayers.append(LobbyPlayer(name: aiName, isHost: false, isReady: true, aiDifficulty: .medium))
    }
    
    private func updateAIDifficulty(playerId: UUID, difficulty: AISkillLevel) {
        if let index = connectedPlayers.firstIndex(where: { $0.id == playerId }) {
            connectedPlayers[index].aiDifficulty = difficulty
        }
    }
    
    private func joinGame() {
        // Implement joining logic
        isHost = false
        showJoinView = false
    }
    
    private func toggleReady() {
        // Implement ready toggle
    }
    
    private func shareCode() {
        let message = "Join my Rachel game! Use code: \(lobbyCode)"
        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            // iPad requires popover presentation
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private static func generateLobbyCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}

struct PlayerRow: View {
    let name: String
    let isHost: Bool
    let isReady: Bool
    let isYou: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(isYou ? Color.blue : Color.gray)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(name.prefix(1)))
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name + (isYou ? " (You)" : ""))
                    .font(.headline)
                    .foregroundColor(.white)
                
                if isHost {
                    Text("Host")
                        .font(.caption)
                        .foregroundColor(.yellow)
                } else if isReady {
                    Text("Ready")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Not Ready")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            if isHost {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
            } else if isReady {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isYou ? Color.blue.opacity(0.3) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal)
    }
}

struct EmptyPlayerSlot: View {
    var body: some View {
        HStack {
            Circle()
                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 40, height: 40)
            
            Text("Waiting for player...")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.5))
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
        )
        .padding(.horizontal)
    }
}

#Preview {
    MultiplayerLobbyView(isPresented: .constant(true)) { players in
        print("Starting game with \(players.count) players")
    }
}

struct AIPlayerRow: View {
    let player: MultiplayerLobbyView.LobbyPlayer
    let onDifficultyChange: (AISkillLevel) -> Void
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(player.name.prefix(1)))
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Difficulty picker
                Menu {
                    Button("Easy") {
                        onDifficultyChange(.easy)
                    }
                    Button("Medium") {
                        onDifficultyChange(.medium)
                    }
                    Button("Hard") {
                        onDifficultyChange(.hard)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(player.aiDifficulty?.name ?? "Medium")
                            .font(.caption)
                            .foregroundColor(difficultyColor)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundColor(difficultyColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(difficultyColor.opacity(0.2))
                    )
                }
            }
            
            Spacer()
            
            Image(systemName: "cpu")
                .foregroundColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    private var difficultyColor: Color {
        switch player.aiDifficulty ?? .medium {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
}

struct MultiplayerTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.white)
            .accentColor(.green)
    }
}