//
//  AISkillLevel.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

enum AISkillLevel: CaseIterable {
    case easy
    case medium
    case hard
    
    var name: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var strategy: AIStrategy {
        switch self {
        case .easy: return EasyAIStrategy()
        case .medium: return MediumAIStrategy()
        case .hard: return HardAIStrategy()
        }
    }
}