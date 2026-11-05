//
//  SimulationView.swift
//  PlanetsSolarSystem
//
//  Created by itkhld on 2024-11-29.
//

import SwiftUI
import SceneKit

struct SimulationView: View {
    @State private var selectedPlanet: Planet?
    @State private var scene = SCNScene()
    @State private var loadError: String?

    /// Shown when the tab first opens, so the scene is never empty.
    private var defaultPlanet: Planet? {
        planets.first { $0.name == "Earth" } ?? planets.first
    }

    var body: some View {
        ZStack {
            Color("SimulationViewBackground")
                .ignoresSafeArea(.all)
            VStack {
                SceneView(
                    scene: scene,
                    pointOfView: nil,
                    // `.rendersContinuously` is intentionally omitted: the models
                    // are static, so SceneKit only needs to redraw on interaction.
                    // This meaningfully reduces battery/GPU usage.
                    options: [.allowsCameraControl, .jitteringEnabled, .temporalAntialiasingEnabled],
                    preferredFramesPerSecond: 60,
                    antialiasingMode: .multisampling4X
                )
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    setupScene()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(planets, id: \.name) { planet in
                            let isSelected = selectedPlanet?.name == planet.name

                            Button {
                                playHaptic(.light)
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedPlanet = planet
                                }
                                updateScene(for: planet)
                            } label: {
                                VStack(spacing: 6) {
                                    Image(planet.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                    Text(planet.name.localizedBodyName)
                                        .font(.caption)
                                        .fontWeight(isSelected ? .bold : .regular)
                                        .foregroundColor(.white)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(Color.white.opacity(isSelected ? 0.18 : 0))
                                .cornerRadius(16)
                                .opacity(isSelected ? 1 : 0.55)
                            }
                            .accessibilityLabel(planet.name.localizedBodyName)
                            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                }
                .background(Color.black)
            }
        }
        .alert("Couldn’t Load Model",
               isPresented: Binding(get: { loadError != nil },
                                    set: { if !$0 { loadError = nil } })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(loadError ?? "")
        }
    }

    func setupScene() {
        // The scene persists across tab switches; only build it the first time
        // so returning to the tab keeps whichever planet was selected.
        guard selectedPlanet == nil else { return }

        scene.background.contents = UIColor.black
        setupLighting()

        // Start on Earth rather than a placeholder model, so the tab opens with
        // something on screen instead of an empty scene.
        if let defaultPlanet {
            selectedPlanet = defaultPlanet
            updateScene(for: defaultPlanet)
        }
    }

    func setupLighting() {
        
        scene.rootNode.childNodes.filter { $0.light != nil }.forEach { $0.removeFromParentNode() }
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .directional
        lightNode.light?.intensity = 1000
        lightNode.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
        scene.rootNode.addChildNode(lightNode)

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.intensity = 200
        scene.rootNode.addChildNode(ambientLightNode)
    }

    func updateScene(for planet: Planet) {
        scene.rootNode.childNodes.filter { $0.name == "planet" }.forEach { $0.removeFromParentNode() }

        if let sceneURL = Bundle.main.url(forResource: planet.planet3DModel, withExtension: "usdz"),
           let planetScene = try? SCNScene(url: sceneURL, options: nil) {

            let planetNode = planetScene.rootNode.clone()
            planetNode.name = "planet"
            planetNode.position = SCNVector3(0, 0, 0)
            planetNode.scale = SCNVector3(1.0, 1.0, 1.0)
            scene.rootNode.addChildNode(planetNode)
        } else {
            loadError = "The 3D model for \(planet.name) is unavailable."
        }
    }
}

#Preview {
    SimulationView()
}
