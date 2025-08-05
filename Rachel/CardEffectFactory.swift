//
//  CardEffectFactory.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

struct CardEffectFactory {
    static func effect(for card: Card) -> CardEffect? {
        switch card.rank {
        case .two:
            return PickUpEffect(count: 2, type: .twos)
        case .seven:
            return SkipEffect()
        case .queen:
            return ReverseEffect()
        case .jack:
            return JackEffect(suit: card.suit)
        case .ace:
            return NominateSuitEffect()
        default:
            return nil
        }
    }
}