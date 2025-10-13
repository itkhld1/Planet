import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {

    var sceneView: ARSCNView!
    var selectedPlanet: Planet?
    var planetNode: SCNNode?
    var selectedStar: Star?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let planets = selectedPlanet else {
            return
        }
        
        sceneView = ARSCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)

        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)

        let loadButton = UIButton(type: .system)
        let showloadButton = UIImage(systemName: "play")
        loadButton.setTitle(" Show \(planets.name)", for: .normal)
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
        
        if deviceType() == "iPhone" {
            loadButton.frame = CGRect(x: 0, y: 100, width: 180, height: 40)
            zoomInButton.frame = CGRect(x: 0, y: 150, width: 100, height: 40)
            zoomOutButton.frame = CGRect(x: 0, y: 150, width: 100, height: 40)
            
            loadButton.center = CGPoint(x: self.view.frame.size.width / 2, y: 650)
            zoomInButton.center = CGPoint(x: self.view.frame.size.width / 3, y: 600)
            zoomOutButton.center = CGPoint(x: 2 * self.view.frame.size.width / 3, y: 600)
        }
        else if deviceType() == "iPad" {
            loadButton.frame = CGRect(x: 0, y: 0, width: 180, height: 40)
            zoomInButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
            zoomOutButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)

            let centerX = self.view.frame.size.width / 2
            let centerY = self.view.frame.size.height / 2

            loadButton.center = CGPoint(x: centerX, y: centerY - 50)      
            zoomInButton.center = CGPoint(x: centerX - 80, y: centerY + 20)
            zoomOutButton.center = CGPoint(x: centerX + 80, y: centerY + 20)
        }
    }

    @objc func loadPlanet() {
        guard let planet = selectedPlanet else {
            print("No planet selected")
            return
        }

        if let sceneURL = Bundle.main.url(forResource: planet.planet3DModel, withExtension: "usdz"),
           let planetScene = try? SCNScene(url: sceneURL, options: nil) {
            planetNode?.removeFromParentNode()
            planetNode = planetScene.rootNode
            planetNode?.position = SCNVector3(0, 0, -0.5)
            planetNode?.scale = SCNVector3(0.1, 0.1, 0.1)
            sceneView.scene.rootNode.addChildNode(planetNode!)
        } else {
            print("Error: Unable to load 3D model for \(planet.name)")
        }
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
}

