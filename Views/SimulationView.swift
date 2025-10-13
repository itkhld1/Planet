//
//  SimulationView.swift
//  PlanetsSolarSystem
//
//  Created by itkhld on 2024-11-29.
//

import SwiftUI
import SceneKit

struct SimulationView: View {
    @State private var selectedPlanet: Planet? = nil
    @State private var scene = SCNScene()
    
    var body: some View {
        ZStack {
            Color("SimulationViewBackground")
                .ignoresSafeArea(.all)
            VStack {
                SceneView(
                    scene: scene,
                    pointOfView: nil,
                    options: [.allowsCameraControl, .jitteringEnabled, .rendersContinuously, .temporalAntialiasingEnabled],
                    preferredFramesPerSecond: 60,
                    antialiasingMode: .multisampling4X
                )
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    setupScene()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(planets, id: \.name) { planet in
                            Button(action: {
                                selectedPlanet = planet
                                updateScene(for: planet)
                            }) {
                                VStack {
                                    Image(planet.imageName)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                    Text(planet.name)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .padding()
                            }
                        }
                    }
                }
                .background(Color.black)
            }
        }
    }

    func setupScene() {
        scene.background.contents = UIColor.black
        if let sceneURL = Bundle.main.url(forResource: "PlaceholderPlanet", withExtension: "usdz"),
           let planetScene = try? SCNScene(url: sceneURL, options: nil) {

            let planetNode = planetScene.rootNode.clone()
            planetNode.name = "planet"
            planetNode.position = SCNVector3(0, 0, 0)
            planetNode.scale = SCNVector3(0.5, 0.5, 0.5)
            scene.rootNode.addChildNode(planetNode)
        }

        setupLighting()
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
            print("Error: Unable to load 3D model for \(planet.name)")
        }
    }
}

#Preview {
    SimulationView()
}
