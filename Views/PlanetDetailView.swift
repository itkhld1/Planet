//
//  PlanetDetailView.swift
//  Planet
//
//  Created by itkhld on 2024-09-30.
//

import SwiftUI
import SceneKit

struct PlanetDetailView: View {
    let planet: Planet
    @State private var showDetailInfo = false
    @State private var show3DModel = false
    @State private var rotatePlanet = false
    @State private var isGradientAnimating = false
    @State private var starAngle: Double = 0
    private let numberOfStars = 100
    
    var body: some View {
        ZStack {
//            LinearGradient(gradient: Gradient(colors: isGradientAnimating ? [Color("LightBlue"),Color("GradientColor")] : [.blue,.black, Color("LightBlue")]),
//                           startPoint: .top, endPoint: .bottom)
            
            LinearGradient(gradient: Gradient(colors: isGradientAnimating ? [Color("D1"),Color("D2"), Color("D3"), Color("D4")] : [Color("D4"), Color("D3"), Color("D2"), Color("D1")]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            .animation(Animation.linear(duration: 5).repeatForever(autoreverses: true), value: isGradientAnimating)
            .onAppear {
                isGradientAnimating = true
            }
            
            // Starts
            ForEach(0..<numberOfStars, id: \.self) { _ in
                Circle()
                    .foregroundColor(.white)
                    .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                              y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
                    .rotationEffect(Angle(degrees: starAngle))
                    .onAppear {
                        withAnimation(Animation.linear(duration: 150).repeatForever(autoreverses: false)) {
                            starAngle = 360
                        }
                    }
            }
            
            VStack {
                Text(planet.name)
                    .font(.custom("AvenirNext-Bold", size: 30))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                
                Image(planet.imageName)
                    .resizable()
                    .frame(width: planet.size * 8, height: planet.size * 8)
                    .rotationEffect(.degrees(rotatePlanet ? 360: 0))
                    .onAppear {
                        withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                            rotatePlanet = true
                        }
                    }
                    .shadow(radius: 5)
                    .padding()
                
                Text("Diameter: \(planet.diameter)")
                    .font(.custom("AvenirNext-Regular", size: 16))
                    .padding(4)
                
                Text("Distance from Sun: \(planet.distanceFromSun)")
                    .font(.custom("AvenirNext-Regular", size: 16))
                    .padding(4)
                
                Text("Day Length: \(planet.dayLength)")
                    .font(.custom("AvenirNext-Regular", size: 16))
                    .padding(4)
                
                Text(planet.description)
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(width: 350, height: 480)
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 15)
            .padding()
            
            VStack {
                Spacer()
                Button(action: {
                    let hapticTouch = UIImpactFeedbackGenerator(style: .medium)
                    hapticTouch.impactOccurred()
                    show3DModel.toggle()
                }, label: {
                    HStack {
                        Image(systemName: "rotate.3d")
                        Text("Explore \(planet.name) 3D")
                            .font(.custom("AvenirNext-Regular", size: 15))
                        
                    }
                    .font(.subheadline)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(30)
                })
                
                Button(action: {
                    let hapticTouch = UIImpactFeedbackGenerator(style: .medium)
                    hapticTouch.impactOccurred()
                    showDetailInfo.toggle()
                }, label: {
                    HStack {
                        Image(systemName: "text.justify.left")
                        Text("Read More")
                            .font(.custom("AvenirNext-Regular", size: 15))
                    }
                    .font(.subheadline)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(30)
                })
                
                .sheet(isPresented: $show3DModel, content: {
                    ViewControllerWrapper(planet: planet)
                        .presentationDragIndicator(.visible)
                })
                
                .sheet(isPresented: $showDetailInfo, content: {
                    PlanetsReadmoreView(planetName: planet.name)
                        .presentationDetents([.height(550), .large])
                        .presentationDragIndicator(.visible)
                })
            }
        }
    }
}
