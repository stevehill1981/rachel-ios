//
//  ThemedBackground.swift
//  Rachel
//
//  Created by Assistant on 07/08/2025.
//

import SwiftUI

struct ThemedBackground: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        ZStack {
            if let gradient = theme.backgroundGradient {
                gradient
                    .ignoresSafeArea()
            } else {
                theme.backgroundColor
                    .ignoresSafeArea()
            }
            
            if let textureImage = theme.baizeTexture {
                Image(textureImage)
                    .resizable(resizingMode: .tile)
                    .opacity(0.1)
                    .ignoresSafeArea()
            }
        }
    }
}

// Note: BaizeBackground is now just a type alias to ThemedBackground
// The original BaizeBackground.swift should be removed or updated

#Preview("Classic Theme") {
    ThemedBackground()
        .environment(\.theme, ClassicTheme())
}

#Preview("Midnight Theme") {
    ThemedBackground()
        .environment(\.theme, MidnightTheme())
}

#Preview("Ocean Theme") {
    ThemedBackground()
        .environment(\.theme, OceanTheme())
}