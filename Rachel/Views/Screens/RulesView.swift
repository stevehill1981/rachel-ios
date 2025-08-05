//
//  RulesView.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Objective
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Objective")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Be the first player to get rid of all your cards!")
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Basic Rules
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to Play")
                            .font(.headline)
                            .foregroundColor(.primary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Match the top card by rank or suit")
                            Text("• If you can't play, pick up a card")
                            Text("• If you can play, you MUST play")
                            Text("• First to empty their hand wins!")
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Special Cards
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Special Cards")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        specialCardRow(rank: "2", effect: "Next player picks up 2 cards")
                        specialCardRow(rank: "8", effect: "Next player skips their turn")
                        specialCardRow(rank: "J", suit: "♠️♣️", effect: "Next player picks up 5 cards")
                        specialCardRow(rank: "J", suit: "♥️♦️", effect: "Cancels black jack pickups")
                        specialCardRow(rank: "Q", effect: "Reverses play direction")
                        specialCardRow(rank: "A", effect: "Choose the next suit")
                    }
                    
                    Divider()
                    
                    // Important Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Important Notes")
                            .font(.headline)
                            .foregroundColor(.primary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• 2s and Black Jacks stack their pickups")
                            Text("• Red Jacks can only counter Black Jacks")
                            Text("• You must play if you have a valid card")
                            Text("• Game continues until only one player has cards")
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("How to Play Rachel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func specialCardRow(rank: String, suit: String? = nil, effect: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            HStack(spacing: 2) {
                Text(rank)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                if let suit = suit {
                    Text(suit)
                        .font(.system(size: 16))
                }
            }
            .frame(width: 40, alignment: .leading)
            
            Text(effect)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    RulesView()
        .preferredColorScheme(.dark)
}