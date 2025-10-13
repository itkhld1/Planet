//
//  SunDetailView.swift
//  Planet
//
//  Created by itkhld on 2024-10-31.
//

import SwiftUI

struct SunDetailView: View {
    let star: Star
    @State private var showDetailInfo = false
    @State private var show3DModel = false
    @State private var isGradientAnimating = false
    @State private var rotatePlanet = false
    @State private var starAngle: Double = 0
    
    let numberOfStars = 100
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: isGradientAnimating ? [.black,.yellow] : [.yellow,.black]),
                           startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            .animation(Animation.linear(duration: 5).repeatForever(autoreverses: true), value: isGradientAnimating)
            .onAppear {
                isGradientAnimating = true
            }
            
            ForEach(0..<numberOfStars, id: \.self) { _ in
                Circle()
                    .foregroundColor(.white)
                    .shadow(color: .yellow, radius: 10)
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
                Text(star.name)
                    .font(.custom("AvenirNext-Bold", size: 30))
                
                Image(star.imageName)
                    .resizable()
                    .frame(width: star.size * 1.5, height: star.size * 1.5)
                    .rotationEffect(.degrees(rotatePlanet ? 360: 0))
                    .onAppear {
                        withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                            rotatePlanet = true
                        }
                    }
                    .shadow(radius: 5)
                    .padding()
                
                Text("Diameter: \(star.diameter)")
                    .font(.custom("AvenirNext-Regular", size: 16))
                    .padding(4)
                
                Text("Distance from Center: \(star.distanceFromCenter)")
                    .font(.custom("AvenirNext-Regular", size: 16))
                    .padding(4)
                
                Text("Surface Temperature: \(star.surfaceTemperature)")
                    .font(.custom("AvenirNext-Regular", size: 16))
                    .padding(4)
                
                Text(star.description)
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .padding()
            }
            .frame(width: 350, height: 480)
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding()
            
            VStack {
                Spacer()
                
//                Button(action: {
//                    let hapticTouch = UIImpactFeedbackGenerator(style: .medium)
//                    hapticTouch.impactOccurred()
//                    show3DModel.toggle()
//                }, label: {
//                    HStack {
//                        Image(systemName: "rotate.3d")
//                        Text("Explore \(star.name) 3D")
//                            .font(.custom("AvenirNext-Regular", size: 15))
//                    }
//                    .font(.subheadline)
//                    .padding(10)
//                    .foregroundColor(.white)
//                    .background(Color.black.opacity(0.2))
//                    .cornerRadius(25)
//                })
                
                Button(action: {
                    let HapticTouch = UIImpactFeedbackGenerator(style: .medium)
                    HapticTouch.impactOccurred()
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
                    .cornerRadius(25)
                })
                
//                .sheet(isPresented: $show3DModel, content: {
//                    ViewControllerWrapper1(star: star)
//                        .presentationDragIndicator(.visible)
//                })
                
                .sheet(isPresented: $showDetailInfo, content: {
                    PlanetsReadmoreView(planetName: sun.name)
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.medium, .large])
                })
            }
        }
    }
}
