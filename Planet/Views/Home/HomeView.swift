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
    @State private var sunAngle: Double = 0
    @State private var zoomScale: CGFloat = 1.0
    @State private var currentDragOffset: CGSize = .zero
    @State private var titleColor: Color = .gray
    @State private var offset = CGSize.zero

    private let numberOfStars = 100
    /// How far the solar system can be panned from center, in points.
    private let maxPan: CGFloat = 300

    /// Whether the view has been panned or zoomed away from its default state.
    private var isOffCenter: Bool {
        offset != .zero || currentDragOffset != .zero || zoomScale != 1.0
    }

    private func clamp(_ value: CGFloat) -> CGFloat {
        min(max(value, -maxPan), maxPan)
    }

    private func recenter() {
        withAnimation(.easeInOut) {
            offset = .zero
            currentDragOffset = .zero
            zoomScale = 1.0
        }
    }
    
    var body: some View {
        if deviceType() == "iPhone" {
            NavigationStack {
                ZStack {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [.black, Color("GradientColor"), .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()

                        StarFieldView(count: numberOfStars)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

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
                            .accessibilityLabel("Sun")
                            .accessibilityHint("Shows details about the Sun")
                            .accessibilityAddTraits(.isButton)
                            .sheet(item: $selectedStar) { star in
                                SunDetailView(star: star)
                                    .appLanguageEnvironment()
                                    .presentationDragIndicator(.visible)
                                    .presentationDetents([.large])
                            }

                        ForEach(planets) { planet in
                            PlanetView(planet: planet, selectedPlanet: $selectedPlanet, zoomScale: zoomScale)
                        }
                    }
                    // The map is a spatial diagram, not text. Mirroring it in
                    // Persian would flip the orbits and put the planets in the
                    // wrong physical order, so this subtree stays left-to-right
                    // while the rest of the app follows the language.
                    .environment(\.layoutDirection, .leftToRight)
                    .offset(x: offset.width + currentDragOffset.width, y: offset.height + currentDragOffset.height)

                    .gesture (
                        DragGesture()
                            .onChanged { gesture in
                                currentDragOffset = CGSize(
                                    width: clamp(offset.width + gesture.translation.width) - offset.width,
                                    height: clamp(offset.height + gesture.translation.height) - offset.height
                                )
                            }
                            .onEnded { _ in
                                offset.width = clamp(offset.width + currentDragOffset.width)
                                offset.height = clamp(offset.height + currentDragOffset.height)
                                currentDragOffset = .zero
                            }
                    )

                    if isOffCenter {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: recenter) {
                                    Image(systemName: "scope")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color.black.opacity(0.35))
                                        .clipShape(Circle())
                                }
                                .accessibilityLabel("Recenter")
                                .padding(.trailing, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Solar System")
                            .font(AppFont.regular(15))
                            .fontWeight(.medium)
                            .foregroundColor(titleColor)
                            .onAppear {
                                withAnimation(Animation.linear(duration: 40).repeatForever(autoreverses: true)) {
                                    titleColor = .white
                                }
                            }
                    }
                    
                }
                .ignoresSafeArea()
                .sheet(item: $selectedPlanet) { planet in
                    PlanetDetailView(planet: planet)
                        .appLanguageEnvironment()
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.large])
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
                        LinearGradient(
                            gradient: Gradient(colors: [.black, Color("GradientColor"), .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()

                        StarFieldView(count: numberOfStars)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
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
                                    .appLanguageEnvironment()
                                    .presentationDragIndicator(.visible)
                                    .presentationDetents([.large])
                            }
                        
                        ForEach(planets) { planet in
                            PlanetView(planet: planet, selectedPlanet: $selectedPlanet, zoomScale: zoomScale)
                                .frame(height: 900)
                                .frame(width: 700)
                        }
                    }
                    // Same as the iPhone branch: the map is a diagram, so it
                    // must not mirror with the language.
                    .environment(\.layoutDirection, .leftToRight)
                    .offset(x: offset.width + currentDragOffset.width, y: offset.height + currentDragOffset.height)
                    
                    .gesture (
                        DragGesture()
                            .onChanged { gesture in
                                currentDragOffset = CGSize(
                                    width: clamp(offset.width + gesture.translation.width) - offset.width,
                                    height: clamp(offset.height + gesture.translation.height) - offset.height
                                )
                            }
                            .onEnded { _ in
                                offset.width = clamp(offset.width + currentDragOffset.width)
                                offset.height = clamp(offset.height + currentDragOffset.height)
                                currentDragOffset = .zero
                            }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Solar System")
                            .font(AppFont.regular(15))
                            .fontWeight(.medium)
                            .foregroundColor(titleColor)
                            .onAppear {
                                withAnimation(Animation.linear(duration: 40).repeatForever(autoreverses: true)) {
                                    titleColor = .white
                                }
                            }
                    }
                    
                }
                .ignoresSafeArea()
                
                .sheet(item: $selectedPlanet) { planet in
                    PlanetDetailView(planet: planet)
                        .appLanguageEnvironment()
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.large])
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
