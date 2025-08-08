//
//  TopBarView.swift
//  Rachel
//
//  Created by Assistant on 07/08/2025.
//

import SwiftUI

struct TopBarView: View {
    @ObservedObject var engine: GameEngine
    let onExit: () -> Void
    @State private var gameStartTime = Date()
    
    var body: some View {
        HStack {
            // Turn counter on the left
            HStack(spacing: 4) {
                Image(systemName: "number.circle")
                Text("Turn \(engine.state.turnCount)")
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.leading, 40)
            .padding(.top, 3)
            
            Spacer()
            
            // Timer on the right - tap to exit
            Button(action: onExit) {
                TimeView(startTime: gameStartTime)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.trailing, 40)
            .padding(.top, 3)
        }
        .frame(height: 59) // Height of Dynamic Island area
        .frame(maxWidth: .infinity)
        .background(
            Color.black
        )
        .onAppear {
            gameStartTime = Date()
        }
        .ignoresSafeArea()
    }
}

struct TimeView: View {
    let startTime: Date
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var timeElapsed: String {
        let elapsed = Int(currentTime.timeIntervalSince(startTime))
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(timeElapsed)
            Image(systemName: "clock")
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
}


#Preview {
    ZStack {
        BaizeBackground()
        VStack {
            TopBarView(engine: {
                let players = [
                    Player(id: "1", name: "You"),
                    Player(id: "2", name: "Computer", isAI: true)
                ]
                let engine = GameEngine(players: players)
                engine.dealCards()
                return engine
            }()) {
                print("Exit tapped")
            }
            Spacer()
        }
    }
}
