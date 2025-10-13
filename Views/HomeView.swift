//
//  HomeView.swift
//  Planet
//
//  Created by itkhld on 2024-10-04.
//

import SwiftUI

struct HomeView: View {
    
    @State private var selectedPlanet: Planet?
    @State private var selectedStar: Star?
    @State private var showAR = false
    @State private var showQuiz = false
    @State private var showCalculate = false
    @State private var showSolarSystem = false
    @State private var isGradientAnimating = false
    @State private var UserGuide = false
    @State private var InstructoinShow = false
    @State private var SolarSystemShow = false
    @State private var sunAngle: Double = 0
    @State private var starAngle: Double = 0
    @State private var zoomScale: CGFloat = 1.0
    @State private var currentDragOffset: CGSize = .zero
    @State private var titleColor: Color = .gray
    @State private var offset = CGSize.zero
    
    private let numberOfStars = 100
    
    var body: some View {
        if deviceType() == "iPhone" {
            NavigationView {
                ZStack {
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: isGradientAnimating ? [.black,Color("GradientColor"), .purple] : [Color("GradientColor")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .edgesIgnoringSafeArea(.all)
                            .animation(Animation.linear(duration: 40).repeatForever(autoreverses: true), value: isGradientAnimating)
                            .onAppear {
                                isGradientAnimating = true
                            }
                        
                        ForEach(0..<numberOfStars, id: \.self) { _ in
                            Circle()
                                .foregroundColor(.white)
                                .shadow(color: .yellow, radius: 10)
                                .frame(width: CGFloat.random(in: 1...2), height: CGFloat.random(in: 1...2))
                                .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
                                .rotationEffect(Angle(degrees: starAngle))
                                .onAppear {
                                    withAnimation(Animation.linear(duration: 150).repeatForever(autoreverses: true)) {
                                        sunAngle = 0
                                    }
                                }
                        }
                        .edgesIgnoringSafeArea(.all)
                    }
                    
                    ZStack {
                        Image("Sun")
                            .resizable()
                            .frame(width: 50 * zoomScale, height: 50 * zoomScale)
                            .rotationEffect(Angle(degrees: sunAngle))
                            .onAppear {
                                withAnimation(Animation.linear(duration: 100).repeatForever(autoreverses: false)) {
                                    sunAngle = 360
                                }
                            }
                            .onTapGesture {
                                selectedStar = sun
                            }
                            .sheet(item: $selectedStar) { star in
                                SunDetailView(star: star)
                                    .presentationDragIndicator(.visible)
                            }
                        
                        ForEach(planets) { planet in
                            PlanetView(planet: planet, selectedPlanet: $selectedPlanet, zoomScale: zoomScale)
                        }
                    }
                    .offset(x: offset.width + currentDragOffset.width, y: offset.height + currentDragOffset.height)
                    
                    .gesture (
                        DragGesture()
                            .onChanged { gesture in
                                currentDragOffset = gesture.translation
                            }
                            .onEnded { _ in
                                offset.width += currentDragOffset.width
                                offset.height += currentDragOffset.height
                                currentDragOffset = .zero
                            }
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            UserGuide.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.gray)
                        }
                        .sheet(isPresented: $UserGuide) {
                            UserGuideView()
                                .presentationDragIndicator(.visible)
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Solar System")
                            .font(.custom("AvenirNext-Regular", size: 15))
                            .fontWeight(.medium)
                            .foregroundColor(titleColor)
                            .onAppear {
                                withAnimation(Animation.linear(duration: 40).repeatForever(autoreverses: true)) {
                                    titleColor = .white
                                }
                            }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            SolarSystemShow.toggle()
                        } label: {
                            Image(systemName: "rotate.3d")
                                .foregroundColor(.gray)
                        }
                        .sheet(isPresented: $SolarSystemShow) {
                            ViewControllerWrapper(planet: Planet(name: "Solar System", size: 0, imageName: "", orbiteRadius: 0, initialAngle: 0, description: "", diameter: "", distanceFromSun: "", dayLength: "", rotationDuration: 0, planet3DModel: "Solar_System_Custom"))
                                .presentationDragIndicator(.visible)
                        }
                        .badge(10)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .sheet(item: $selectedPlanet) { planet in
                    PlanetDetailView(planet: planet)
                        .presentationDragIndicator(.visible)
                }
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            zoomScale = min(max(0.5, value), 3.0)
                        }
                )
            }
        }
        else if deviceType() == "iPad" {
            NavigationStack {
                ZStack {
                    ZStack {
                        Color.black
//                        LinearGradient(gradient: Gradient(colors: isGradientAnimating ? [.black,Color("GradientColor"), .purple] : [Color("GradientColor")]), startPoint: .top, endPoint: .bottom)
//                            .edgesIgnoringSafeArea(.all)
//                            .animation(Animation.linear(duration: 40).repeatForever(autoreverses: true), value: isGradientAnimating)
//                            .onAppear {
//                                isGradientAnimating = true
//                            }
                        
                        ForEach(0..<numberOfStars, id: \.self) { _ in
                            Circle()
                                .foregroundColor(.white)
                                .shadow(color: .yellow, radius: 10)
                                .frame(width: CGFloat.random(in: 1...2), height: CGFloat.random(in: 1...2))
                                .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
                                .rotationEffect(Angle(degrees: starAngle))
//                                .onAppear {
//                                    withAnimation(Animation.linear(duration: 150).repeatForever(autoreverses: true)) {
//                                        sunAngle = 0
//                                    }
//                                }
                        }
                        .edgesIgnoringSafeArea(.all)
                    }
                    
                    ZStack {
                        ZStack {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 60, height: 60)
                                .blur(radius: 10)
                                .opacity(0.3)
    
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 120, height: 120)
                                .blur(radius: 20)
                                .opacity(0.3)
    
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 300, height: 300)
                                .blur(radius: 30)
                                .opacity(0.2)
                        }
                        
                        Image("Sun")
                            .resizable()
                            .frame(width: 50 * zoomScale, height: 50 * zoomScale)
                            .rotationEffect(Angle(degrees: sunAngle))
//                            .onAppear {
//                                withAnimation(Animation.linear(duration: 100).repeatForever(autoreverses: false)) {
//                                    sunAngle = 360
//                                }
//                            }
                            .onTapGesture {
                                selectedStar = sun
                            }
                            .sheet(item: $selectedStar) { star in
                                SunDetailView(star: star)
                                    .presentationDragIndicator(.visible)
                            }
                        
                        ForEach(planets) { planet in
                            PlanetView(planet: planet, selectedPlanet: $selectedPlanet, zoomScale: zoomScale)
                                .frame(height: 900)
                                .frame(width: 700)
                        }
                    }
                    .offset(x: offset.width + currentDragOffset.width, y: offset.height + currentDragOffset.height)
                    
                    .gesture (
                        DragGesture()
                            .onChanged { gesture in
                                currentDragOffset = gesture.translation
                            }
                            .onEnded { _ in
                                offset.width += currentDragOffset.width
                                offset.height += currentDragOffset.height
                                currentDragOffset = .zero
                            }
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            UserGuide.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.gray)
                        }
                        .sheet(isPresented: $UserGuide) {
                            UserGuideView()
                                .presentationDragIndicator(.visible)
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Solar System")
                            .font(.custom("AvenirNext-Regular", size: 15))
                            .fontWeight(.medium)
                            .foregroundColor(titleColor)
                            .onAppear {
                                withAnimation(Animation.linear(duration: 40).repeatForever(autoreverses: true)) {
                                    titleColor = .white
                                }
                            }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            SolarSystemShow.toggle()
                        } label: {
                            Image(systemName: "rotate.3d")
                                .foregroundColor(.gray)
                        }
                        .sheet(isPresented: $SolarSystemShow) {
                            ViewControllerWrapper(planet: Planet(name: "Solar System", size: 0, imageName: "", orbiteRadius: 0, initialAngle: 0, description: "", diameter: "", distanceFromSun: "", dayLength: "", rotationDuration: 0, planet3DModel: "Solar_System_Custom"))
                                .presentationDragIndicator(.visible)
                                .frame(height: 900)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                .sheet(item: $selectedPlanet) { planet in
                    PlanetDetailView(planet: planet)
                        .presentationDragIndicator(.visible)
                }
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            zoomScale = min(max(0.5, value), 3.0)
                        }
                )
            }
        }

    }
}


#Preview {
    HomeView()
}
