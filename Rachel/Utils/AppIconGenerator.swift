//
//  AppIconGenerator.swift
//  Rachel
//
//  Created by Steve Hill on 07/08/2025.
//

import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.4, blue: 0.2), // Dark green
                    Color(red: 0.0, green: 0.2, blue: 0.1)  // Darker green
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Card fan arrangement
            ZStack {
                // Ace of Spades (back-left)
                Image("spades-ace")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400, height: 560)
                    .rotationEffect(.degrees(-15))
                    .offset(x: -100, y: -50)
                    .shadow(radius: 20)
                
                // Queen of Hearts (middle)
                Image("hearts-queen")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400, height: 560)
                    .rotationEffect(.degrees(0))
                    .offset(x: 0, y: 0)
                    .shadow(radius: 20)
                
                // Seven of Diamonds (front-right)
                Image("diamonds-7")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400, height: 560)
                    .rotationEffect(.degrees(15))
                    .offset(x: 100, y: 50)
                    .shadow(radius: 20)
            }
            .scaleEffect(0.8)
            
            // App name overlay at bottom
            VStack {
                Spacer()
                Text("RACHEL")
                    .font(.system(size: 180, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 80)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

#Preview {
    AppIconView()
        .previewLayout(.fixed(width: 1024, height: 1024))
}

// Helper to export icon - run this in a playground or test
#if DEBUG
import UIKit

extension AppIconView {
    func exportIcon() {
        let controller = UIHostingController(rootView: self)
        controller.view.frame = CGRect(x: 0, y: 0, width: 1024, height: 1024)
        controller.view.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1024, height: 1024))
        let image = renderer.image { context in
            controller.view.layer.render(in: context.cgContext)
        }
        
        // Save to desktop or documents
        if let data = image.pngData() {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("RachelAppIcon.png")
            try? data.write(to: url)
            print("Icon saved to: \(url)")
        }
    }
}
#endif