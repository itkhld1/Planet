//
//  ContentView.swift
//  Planets
//
//  Created by itkhld on 2.04.2025.
//

import SwiftUI

extension UserDefaults {
    var AppInstruction: Bool {
        get {
            return(UserDefaults.standard.value(forKey: "AppInstruction") as? Bool) ?? false
        } set {
            UserDefaults.standard.setValue(newValue, forKey: "AppInstruction")
        }
    }
}

struct ContentView: View {
    var body: some View {
        if UserDefaults.standard.AppInstruction {
            CustomTabBar()
        } else {
            AppInstruction()
        }
    }
}

#Preview {
    ContentView()
}
