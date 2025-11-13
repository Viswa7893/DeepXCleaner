//
//  ModernCircularProgressViewStyle.swift
//  DeepXCleaner
//
//  Created by Durga Viswanadh on 10/11/25.
//


import SwiftUI

struct ModernCircularProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        let progress = configuration.fractionCompleted ?? 0
        
        return ZStack {
            // Background ring
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.gray.opacity(0.2), .gray.opacity(0.05)]),
                        center: .center
                    ),
                    lineWidth: 8
                )
            
            // Progress ring with gradient + glow
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.8),
                            Color.purple.opacity(0.9),
                            Color.cyan.opacity(0.8)
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Color.cyan.opacity(0.6), radius: 6, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.4), value: progress)
            
            // Progress label in the center
            Text("\(Int(progress * 100))%")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .shadow(radius: 3)
        }
        .padding(10)
    }
}
