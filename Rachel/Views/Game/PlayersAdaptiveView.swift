//
//  PlayersAdaptiveView.swift
//  Rachel
//
//  Created by Steve Hill on 06/08/2025.
//

import SwiftUI

struct PlayersAdaptiveView: View {
    @ObservedObject var engine: GameEngine
    @ObservedObject var aiCoordinator: AITurnCoordinator
    @AppStorage("preferredPlayerLayout") private var preferredLayout = PlayerLayout.automatic
    
    enum PlayerLayout: String, CaseIterable {
        case automatic = "auto"
        case circle = "circle"
        case grid = "grid"
        case list = "list"
        
        var displayName: String {
            switch self {
            case .automatic: return "Auto"
            case .circle: return "Circle"
            case .grid: return "Grid"
            case .list: return "List"
            }
        }
    }
    
    var effectiveLayout: PlayerLayout {
        if preferredLayout != .automatic {
            return preferredLayout
        }
        
        // Auto-select based on player count
        switch engine.state.players.count {
        case 2...4:
            return .circle  // Circle works well for 2-4 players
        case 5...6:
            return .grid   // Grid is better for 5-6
        case 7...8:
            return .list   // List is most readable for 7-8
        default:
            return .grid
        }
    }
    
    var body: some View {
        Group {
            switch effectiveLayout {
            case .automatic, .circle:
                PlayersView(engine: engine, aiCoordinator: aiCoordinator)
            case .grid:
                PlayersGridView(engine: engine, aiCoordinator: aiCoordinator)
            case .list:
                PlayersListView(engine: engine, aiCoordinator: aiCoordinator)
            }
        }
    }
}

// Settings view for testing different layouts
struct PlayerLayoutPicker: View {
    @AppStorage("preferredPlayerLayout") private var preferredLayout = PlayersAdaptiveView.PlayerLayout.automatic
    
    var body: some View {
        Picker("Player Layout", selection: $preferredLayout) {
            ForEach(PlayersAdaptiveView.PlayerLayout.allCases, id: \.self) { layout in
                Text(layout.displayName).tag(layout)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(8)
    }
}

#Preview("4 Players") {
    ZStack {
        BaizeBackground()
        
        VStack {
            let players = [
                Player(id: "1", name: "You"),
                Player(id: "2", name: "Alex", isAI: true, aiSkillLevel: .easy),
                Player(id: "3", name: "Sam", isAI: true, aiSkillLevel: .medium),
                Player(id: "4", name: "Jamie", isAI: true, aiSkillLevel: .hard)
            ]
            
            let engine = GameEngine(players: players)
            let aiCoordinator = AITurnCoordinator(engine: engine)
            
            PlayersAdaptiveView(engine: engine, aiCoordinator: aiCoordinator)
                .frame(maxHeight: 250)
                .onAppear {
                    engine.dealCards()
                    engine.updateState { state in
                        state.currentPlayerIndex = 2
                    }
                }
            
            Spacer()
        }
        .padding()
    }
}

#Preview("8 Players") {
    ZStack {
        BaizeBackground()
        
        VStack {
            let players = [
                Player(id: "1", name: "You"),
                Player(id: "2", name: "Alex", isAI: true, aiSkillLevel: .easy),
                Player(id: "3", name: "Sam", isAI: true, aiSkillLevel: .medium),
                Player(id: "4", name: "Jamie", isAI: true, aiSkillLevel: .hard),
                Player(id: "5", name: "Casey", isAI: true, aiSkillLevel: .easy),
                Player(id: "6", name: "Jordan", isAI: true, aiSkillLevel: .medium),
                Player(id: "7", name: "Morgan", isAI: true, aiSkillLevel: .hard),
                Player(id: "8", name: "Riley", isAI: true, aiSkillLevel: .easy)
            ]
            
            let engine = GameEngine(players: players)
            let aiCoordinator = AITurnCoordinator(engine: engine)
            
            VStack {
                Text("8 Players - Auto selects List Layout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom)
                
                PlayersAdaptiveView(engine: engine, aiCoordinator: aiCoordinator)
                    .frame(maxHeight: 250)
            }
            .onAppear {
                engine.dealCards()
                engine.updateState { state in
                    state.currentPlayerIndex = 3
                }
            }
            
            Spacer()
        }
        .padding()
    }
}