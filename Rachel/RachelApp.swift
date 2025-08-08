//
//  RachelApp.swift
//  Rachel
//
//  Created by Steve Hill on 05/08/2025.
//

import SwiftUI

@main
struct RachelApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .themed()
        }
    }
}
