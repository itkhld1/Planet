//
//  ARPlanetView.swift
//  Planet
//
//  Place a 3D planet in the room: pick a world, point at a table or the
//  floor, tap to drop it, then pinch to resize, twist to rotate and drag to
//  move it.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

// MARK: - Controller

/// Owns the ARView so SwiftUI buttons can drive it.
@MainActor
@Observable
final class ARPlanetController {
    /// Built on first use: `@State` creates a controller every time the view
    /// struct is initialised and keeps only the first, so the init must stay
    /// cheap — no camera view for the discarded ones.
    @ObservationIgnored private(set) lazy var arView: ARView = {
        let view = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        let coaching = ARCoachingOverlayView()
        coaching.session = view.session
        coaching.goal = .horizontalPlane
        coaching.activatesAutomatically = true
        coaching.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(coaching)
        view.environment.lighting.intensityExponent = 1
        return view
    }()

    var isLoading = false
    var placedCount = 0
    var errorMessage: String?

    @ObservationIgnored private var anchors: [AnchorEntity] = []
    @ObservationIgnored private var loadRequest: AnyCancellable?
    @ObservationIgnored private var isRunning = false

    static var isSupported: Bool { ARWorldTrackingConfiguration.isSupported }

    func start() {
        guard Self.isSupported, !isRunning else { return }
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config)
        isRunning = true
    }

    /// Stops the camera when the screen isn't visible, to save battery.
    func pause() {
        guard isRunning else { return }
        arView.session.pause()
        isRunning = false
    }

    func clear() {
        anchors.forEach { $0.removeFromParent() }
        anchors.removeAll()
        placedCount = 0
    }

    /// Drops the model where the user tapped, or 80 cm in front of the camera
    /// if no surface has been found there yet.
    func place(modelNamed name: String, at point: CGPoint) {
        guard !isLoading else { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: "usdz") else {
            errorMessage = String(localized: "This 3D model is unavailable.", bundle: Bundle.appLanguage)
            return
        }

        let anchor: AnchorEntity
        if let hit = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .horizontal).first {
            anchor = AnchorEntity(world: hit.worldTransform)
        } else {
            var transform = arView.cameraTransform
            let forward = -transform.matrix.columns.2
            transform.translation += SIMD3(forward.x, forward.y, forward.z) * 0.8
            transform.rotation = simd_quatf(angle: 0, axis: [0, 1, 0])
            anchor = AnchorEntity(world: transform.matrix)
        }

        isLoading = true
        loadRequest = Entity.loadAsync(contentsOf: url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure = completion {
                    self.errorMessage = String(localized: "This 3D model is unavailable.", bundle: Bundle.appLanguage)
                }
            } receiveValue: { [weak self] model in
                self?.add(model, to: anchor)
            }
    }

    private func add(_ model: Entity, to anchor: AnchorEntity) {
        // Models come in wildly different sizes; normalise to ~30 cm across.
        //
        // The model's root already carries its own transform (these files
        // ship with a 0.01 scale), so it is wrapped rather than rescaled —
        // overwriting `model.scale` threw that away and made every planet
        // ~100× too big, with the camera stuck inside it.
        let content = Entity()
        content.addChild(model)
        let bounds = content.visualBounds(relativeTo: nil)
        let largest = max(bounds.extents.x, bounds.extents.y, bounds.extents.z)
        let scale = largest > 0 ? 0.3 / largest : 1
        content.scale = SIMD3(repeating: scale)
        // Centre the model on the spinner, so it turns in place.
        content.position = -bounds.center * scale

        // Sits the planet on the surface rather than half-buried in it, and
        // is what the spin animation turns.
        let size = bounds.extents * scale
        let spinner = Entity()
        spinner.position = [0, size.y / 2, 0]
        spinner.addChild(content)

        // A collision box on a wrapper entity is what lets the built-in
        // pinch / rotate / drag gestures grab the model.
        let holder = ModelEntity()
        holder.addChild(spinner)
        holder.collision = CollisionComponent(shapes: [
            ShapeResource.generateBox(size: size).offsetBy(translation: [0, size.y / 2, 0])
        ])
        anchor.addChild(holder)
        arView.scene.addAnchor(anchor)
        arView.installGestures([.rotation, .scale, .translation], for: holder)

        // Gentle spin so it reads as a planet, not a still. The spinner sits
        // on the axis, so the "orbit" has zero radius and only rotates it.
        if let animation = try? AnimationResource.generate(with: OrbitAnimation(
            duration: 30, axis: [0, 1, 0], startTransform: spinner.transform,
            spinClockwise: false, orientToPath: true, rotationCount: 1,
            bindTarget: .transform, repeatMode: .repeat)) {
            spinner.playAnimation(animation)
        }

        anchors.append(anchor)
        placedCount = anchors.count
        playNotificationHaptic(.success)
    }
}

// MARK: - UIKit bridge

private struct ARContainer: UIViewRepresentable {
    let controller: ARPlanetController
    let onTap: (CGPoint) -> Void

    func makeUIView(context: Context) -> ARView {
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped(_:)))
        controller.arView.addGestureRecognizer(tap)
        return controller.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.onTap = onTap
    }

    func makeCoordinator() -> Coordinator { Coordinator(onTap: onTap) }

    final class Coordinator: NSObject {
        var onTap: (CGPoint) -> Void
        init(onTap: @escaping (CGPoint) -> Void) { self.onTap = onTap }

        @objc func tapped(_ recognizer: UITapGestureRecognizer) {
            onTap(recognizer.location(in: recognizer.view))
        }
    }
}

// MARK: - Screen

struct ARPlanetView: View {
    @State private var controller = ARPlanetController()
    @State private var selected: String

    /// Set when shown as a sheet (from a planet's detail screen): drag-to-dismiss
    /// fights the AR drag gesture, so the screen gets its own close button.
    private let onClose: (() -> Void)?

    init(initialPlanet: String = "Earth", onClose: (() -> Void)? = nil) {
        _selected = State(initialValue: initialPlanet)
        self.onClose = onClose
    }

    /// Every model in the bundle, in order from the Sun.
    private let choices: [Planet] = planets.filter { !$0.planet3DModel.isEmpty }

    var body: some View {
        Group {
            if ARPlanetController.isSupported {
                arContent
            } else {
                unsupported
            }
        }
        .alert("Couldn’t Load Model",
               isPresented: Binding(get: { controller.errorMessage != nil },
                                    set: { if !$0 { controller.errorMessage = nil } })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(controller.errorMessage ?? "")
        }
    }

    private var arContent: some View {
        ZStack {
            ARContainer(controller: controller) { point in
                let model = choices.first { $0.name == selected }?.planet3DModel ?? selected
                controller.place(modelNamed: model, at: point)
            }
            .ignoresSafeArea()
            .onAppear { controller.start() }
            .onDisappear { controller.pause() }

            VStack {
                if let onClose {
                    HStack {
                        Spacer()
                        Button {
                            playHaptic(.light)
                            onClose()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(.ultraThinMaterial))
                                .environment(\.colorScheme, .dark)
                        }
                        .accessibilityLabel("Close")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                hint
                Spacer()
                if controller.placedCount > 0 {
                    Button {
                        playHaptic(.light)
                        controller.clear()
                    } label: {
                        Label("Clear", systemImage: "trash")
                            .font(AppFont.bold(14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(.ultraThinMaterial))
                            .environment(\.colorScheme, .dark)
                    }
                }
                planetStrip
            }
            .padding(.bottom, 8)

            if controller.isLoading {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.4)
                    .padding(24)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
                    .environment(\.colorScheme, .dark)
            }
        }
    }

    private var hint: some View {
        Text(controller.placedCount == 0
             ? "Point at a table or the floor, then tap to place \(selected.localizedBodyName)."
             : "Pinch to resize, twist to rotate, drag to move. Tap again to add another.")
            .font(AppFont.regular(13))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            // Not a capsule: the hint often wraps to two lines.
            .background(RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial))
            .environment(\.colorScheme, .dark)
            .padding(.top, 8)
            .padding(.horizontal, 20)
    }

    private var planetStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(choices) { planet in
                    let isSelected = planet.name == selected
                    Button {
                        playHaptic(.light)
                        selected = planet.name
                    } label: {
                        VStack(spacing: 4) {
                            Group {
                                if UIImage(named: planet.imageName) != nil {
                                    Image(planet.imageName).resizable().scaledToFit()
                                } else {
                                    Image(systemName: "circle.hexagongrid.fill")
                                        .resizable().scaledToFit().foregroundColor(.orange)
                                }
                            }
                            .frame(width: 40, height: 40)
                            Text(planet.name.localizedBodyName)
                                .font(AppFont.regular(11))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(isSelected ? 0.25 : 0)))
                        .opacity(isSelected ? 1 : 0.7)
                    }
                    .accessibilityLabel(planet.name.localizedBodyName)
                    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial))
        .environment(\.colorScheme, .dark)
        .padding(.horizontal, 12)
        // Planets are ordered from the Sun; keep that physical order in Persian too.
        .environment(\.layoutDirection, .leftToRight)
    }

    private var unsupported: some View {
        ZStack {
            SpaceBackground(stars: 60)
            VStack(spacing: 14) {
                Image(systemName: "arkit")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.7))
                Text("AR isn't available on this device")
                    .font(AppFont.bold(18))
                    .foregroundColor(.white)
                Text("You can still turn every planet in 3D on the 3D Planets screen.")
                    .font(AppFont.regular(14))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(32)
        }
    }
}

#Preview {
    ARPlanetView()
}
