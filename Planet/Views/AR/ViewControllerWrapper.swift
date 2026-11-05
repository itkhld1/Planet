//
//  ViewControllerWrapper.swift
//  Planet
//
//  Created by itkhld on 2024-10-06.
//

import SwiftUI
import ARKit
import UIKit

struct ViewControllerWrapper: UIViewControllerRepresentable {
    let planet: Planet
    
    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController()
        viewController.selectedPlanet = planet
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
}

