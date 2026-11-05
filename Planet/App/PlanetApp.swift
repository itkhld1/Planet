//
//  PlanetApp.swift
//  Planet
//
//  Created by itkhld on 13.07.2026.
//

import SwiftUI

@main
struct PlanetApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Before the first view is built, so nothing renders in the wrong
        // language for a frame.
        AppLanguage.apply()
        ReviewPrompt.recordLaunch()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
