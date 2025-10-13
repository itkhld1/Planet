//
//  PlanetView.swift
//  Planet
//
//  Created by itkhld on 2024-09-30.
//

import SwiftUI
import SceneKit

struct PlanetView: View {
    
    let planet: Planet
    @Binding var selectedPlanet: Planet?
    @State private var angle: Double = 0
    @State private var currentAngle: Double = 0
    var zoomScale: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                .frame(width: planet.orbiteRadius * 2 * zoomScale, height: planet.orbiteRadius * 2 * zoomScale)
        }
        
        Image(planet.imageName)
            .resizable()
            .frame(width: planet.size * 2 * zoomScale, height: planet.size * 2 * zoomScale)
            .offset(x: planet.orbiteRadius * zoomScale, y: 0)
            .rotationEffect(Angle(degrees: currentAngle + planet.initialAngle))
            .onAppear {
                withAnimation(Animation.linear(duration: planet.rotationDuration).repeatForever(autoreverses: false)) {
                    currentAngle = 360
                }
            }
            .onTapGesture {
                selectedPlanet = planets.first { $0.name == planet.name }
            }
    }
}


