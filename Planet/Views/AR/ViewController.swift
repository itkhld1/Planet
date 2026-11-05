import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {

    var sceneView: ARSCNView!
    var selectedPlanet: Planet?
    var planetNode: SCNNode?

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView = ARSCNView(frame: self.view.frame)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(sceneView)

        let loadButton = UIButton(type: .system)
        let showloadButton = UIImage(systemName: "play")
        let name = (selectedPlanet?.name ?? "Planet").localizedBodyName
        loadButton.setTitle(" " + String(format: String(localized: "Show %@", bundle: Bundle.appLanguage), name), for: .normal)
        loadButton.setImage(showloadButton, for: .normal)
        loadButton.tintColor = .white
        loadButton.setTitleColor(.white, for: .normal)
        loadButton.addTarget(self, action: #selector(loadPlanet), for: .touchUpInside)
        loadButton.backgroundColor = UIColor.systemGray3.withAlphaComponent(0.4)
        loadButton.layer.cornerRadius = 20
        loadButton.clipsToBounds = true
        self.view.addSubview(loadButton)

        let zoomInButton = UIButton(type: .system)
        let zoomInImage = UIImage(systemName: "plus.magnifyingglass")
        //zoomInButton.setTitle("+", for: .normal)
        zoomInButton.tintColor = .white
        zoomInButton.setTitleColor(.white, for: .normal)
        zoomInButton.setImage(zoomInImage, for: .normal)
        zoomInButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        zoomInButton.backgroundColor = UIColor.systemGray3.withAlphaComponent(0.4)
        zoomInButton.layer.cornerRadius = 20
        zoomInButton.clipsToBounds = true
        self.view.addSubview(zoomInButton)

        let zoomOutButton = UIButton(type: .system)
        let zoomOutImage = UIImage(systemName: "minus.magnifyingglass")
        zoomOutButton.setImage(zoomOutImage, for: .normal)
        //zoomOutButton.setTitle("-", for: .normal)
        zoomOutButton.tintColor = .white
        zoomOutButton.setTitleColor(.white, for: .normal)
        zoomOutButton.backgroundColor = UIColor.systemGray3.withAlphaComponent(0.4)
        zoomOutButton.layer.cornerRadius = 20
        zoomOutButton.clipsToBounds = true
        zoomOutButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        self.view.addSubview(zoomOutButton)

        // Pinned to the safe area so the controls sit just above the bottom
        // edge on every screen size, instead of at a fixed y that only
        // suited one iPhone.
        [loadButton, zoomInButton, zoomOutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            loadButton.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            loadButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -32),
            loadButton.heightAnchor.constraint(equalToConstant: 44),
            loadButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 180),

            zoomInButton.trailingAnchor.constraint(equalTo: guide.centerXAnchor, constant: -8),
            zoomInButton.bottomAnchor.constraint(equalTo: loadButton.topAnchor, constant: -12),
            zoomInButton.widthAnchor.constraint(equalToConstant: 100),
            zoomInButton.heightAnchor.constraint(equalToConstant: 40),

            zoomOutButton.leadingAnchor.constraint(equalTo: guide.centerXAnchor, constant: 8),
            zoomOutButton.bottomAnchor.constraint(equalTo: loadButton.topAnchor, constant: -12),
            zoomOutButton.widthAnchor.constraint(equalToConstant: 100),
            zoomOutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        zoomInButton.accessibilityLabel = String(localized: "Zoom in", bundle: Bundle.appLanguage)
        zoomOutButton.accessibilityLabel = String(localized: "Zoom out", bundle: Bundle.appLanguage)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Only start the AR session while the view is on screen.
        guard ARWorldTrackingConfiguration.isSupported else {
            showAlert(title: "AR Unavailable",
                      message: "This device does not support world tracking, so the AR view can’t be shown.")
            return
        }
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop tracking + camera when the view goes away to save battery.
        sceneView.session.pause()
    }

    @objc func loadPlanet() {
        guard let planet = selectedPlanet else {
            showAlert(title: "No Planet Selected",
                      message: "Choose a planet before loading its 3D model.")
            return
        }

        guard let sceneURL = Bundle.main.url(forResource: planet.planet3DModel, withExtension: "usdz"),
              let planetScene = try? SCNScene(url: sceneURL, options: nil) else {
            showAlert(title: "Couldn’t Load Model",
                      message: "The 3D model for \(planet.name) is unavailable.")
            return
        }

        planetNode?.removeFromParentNode()
        planetNode = planetScene.rootNode
        // Spawn the model smaller and further away so it's fully visible on
        // load instead of filling the camera (previously required zooming out).
        planetNode?.position = SCNVector3(0, 0, -1.0)
        planetNode?.scale = SCNVector3(0.02, 0.02, 0.02)
        sceneView.scene.rootNode.addChildNode(planetNode!)
    }

    @objc func zoomIn() {
        guard let planetNode = planetNode else {
            return
        }
        planetNode.scale = SCNVector3(planetNode.scale.x * 1.2, planetNode.scale.y * 1.2, planetNode.scale.z * 1.2)
    }

    @objc func zoomOut() {
        guard let planetNode = planetNode else {
            return
        }
        planetNode.scale = SCNVector3(planetNode.scale.x * 0.8, planetNode.scale.y * 0.8, planetNode.scale.z * 0.8)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
