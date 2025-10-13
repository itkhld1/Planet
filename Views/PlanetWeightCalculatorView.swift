//
//  PlanetWeightCalculatorView.swift
//  Planet
//
//  Created by itkhld on 2024-09-30.
//

import SwiftUI

struct PlanetWeightCalculatorView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var weightOnEarth = ""
    @State private var starAngle: Double = 0
    @State private var isGradientAnimating = false
    @State private var calculatedWeights: [(String, Double)] = []
    @State private var ageOnEarth = ""
    @State private var calculatedAges: [(String, Double)] = []
    
    let numberOfStars = 10
    
    let planets = [
        ("Earth", 1.00, 1.00),
        ("Mercury", 0.38, 0.241),
        ("Venus", 0.91, 0.615),
        ("Mars", 0.38, 1.88),
        ("Jupiter", 2.34, 11.86),
        ("Saturn", 1.06, 29.46),
        ("Uranus", 0.92, 84.01),
        ("Neptune", 1.19, 164.79)
    ]
    
    var body: some View {
        
        if deviceType() == "iPhone" {
            NavigationView {
                ZStack {
                    backgroundGradient
                    
                    ForEach(0..<numberOfStars, id: \.self) { _ in
                        Circle()
                            .foregroundColor(.white)
                            .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                            .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
                            .rotationEffect(Angle(degrees: starAngle))
                            .onAppear {
                                withAnimation(Animation.linear(duration: 150).repeatForever(autoreverses: false)) {
                                    starAngle = 360.0
                                }
                            }
                    }
                    
                    VStack(spacing: 20) {
                        headerText("Planetary Calculators", subtitle: "Explore Cosmic Calculations")
                            .padding(.vertical, 100)
                        calculatorNavigationLinks
                            .padding(.top)
                        Spacer()
                    }
                    .padding()
                }
                .navigationBarHidden(true)
            }
        }
        else if deviceType() == "iPad" {
            NavigationStack {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: isGradientAnimating
                                           ? [Color("1c3e35"), Color("99f2d1")]
                                           : [Color("99f2d1"), Color("1c3e35")]),startPoint: .top,endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                    .animation(Animation.linear(duration: 5).repeatForever(autoreverses: true), value: isGradientAnimating)
                    .edgesIgnoringSafeArea(.all)
                    .animation(Animation.linear(duration: 5).repeatForever(autoreverses: true), value: isGradientAnimating)
                    
                    ForEach(0..<numberOfStars, id: \.self) { _ in
                        Circle()
                            .foregroundColor(.white)
                            .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                            .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
                            .rotationEffect(Angle(degrees: starAngle))
                    }
                    
                    VStack(spacing: 20) {
                        headerText("Planetary Calculators", subtitle: "Explore Cosmic Calculations")
                        
                        calculatorNavigationLinks
                            .padding(.top)
                    }
                    .padding()
                }
                .navigationBarHidden(true)
            }

        }
    }
    private var calculatorNavigationLinks: some View {
        VStack(spacing: 35) {
            NavigationLink(destination: weightCalculationView) {
                calculatorLinkStyle(
                    title: "Weight Calculator",
                    subtitle: "Calculate Your Weight on Different Planets",
                    systemImage: "scalemass"
                )
            }
            
            NavigationLink(destination: ageCalculationView) {
                calculatorLinkStyle(
                    title: "Age Calculator",
                    subtitle: "Your Age on Different Planetary Orbits",
                    systemImage: "birthday.cake"
                )
            }
        }
    }
    private func calculatorLinkStyle(title: String, subtitle: String, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
                .font(.custom("headline", size: deviceType() == "iPhone" ? 16 : 30))
                .foregroundColor(.white)
                .imageScale(.large)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.custom("headline", size: deviceType() == "iPhone" ? 16 : 30))
                    //.font(.headline)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.custom("caption", size: deviceType() == "iPhone" ? 12 : 24))
                    //.font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.custom("headline", size: deviceType() == "iPhone" ? 16 : 30))
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(35)
    }
    private var weightCalculationView: some View {
        
        ZStack {
            backgroundGradient
            
            VStack {
                headerText("Weight Calculator", subtitle: "Calculate & See Your Weight in Other Planets")
                
                TextField("Enter your weight on Earth (kg)", text: $weightOnEarth)
                    .textFieldStyle()
                    .font(.custom("AvenirNext-Regular", size: deviceType() == "iPhone" ? 10 : 20 ))
                
                Button(action: {
                    let HapticTouch = UIImpactFeedbackGenerator(style: .medium)
                    HapticTouch.impactOccurred()
                    calculateWeight()
                }) {
                    Text("Calculate")
                        .font(.custom("AvenirNext-Regular", size: 19))
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(35)
                }
                .padding(.top, 0)
                
                Spacer()
                
                ScrollView {
                    if !calculatedWeights.isEmpty {
                        VStack(alignment: .center) {
                            //                            Text("Weights")
                            //                                .font(.custom("AvenirNext-Regular", size: 19))
                            //                                .padding(.top)
                            
                            ForEach(calculatedWeights, id: \.0) { planet, weight in
                                HStack {
                                    Text(planet)
                                    Spacer()
                                    Text("\(String(format: "%.2f", weight)) kg")
                                }
                                .font(.custom("AvenirNext-Regular", size: 15))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.9))
                                .cornerRadius(25)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .padding()
        }
        
        .onTapGesture {
            hideKeyboard()
        }
    }
    private var ageCalculationView: some View {
        
        ZStack {
            backgroundGradient
            
            VStack {
                headerText("Age Calculator", subtitle: "Your Age on Different Planets")
                
                TextField("Enter your age on Earth", text: $ageOnEarth)
                    .textFieldStyle()
                
                Button(action: {
                    let HapticTouch = UIImpactFeedbackGenerator(style: .medium)
                    HapticTouch.impactOccurred()
                    calculateAge()
                }) {
                    Text("Calculate")
                        .font(.custom("AvenirNext-Regular", size: 19))
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(35)
                }
                .padding(.top, 0)
                
                Spacer()
                
                ScrollView {
                    if !calculatedAges.isEmpty {
                        VStack(alignment: .center) {
//                            Text("Ages")
//                                .font(.custom("AvenirNext-Regular", size: 19))
//                                .padding(.top)
                            
                            ForEach(calculatedAges, id: \.0) { planet, age in
                                HStack {
                                    Text(planet)
                                    Spacer()
                                    Text("\(String(format: "%.2f", age)) Y/O")
                                    
                                }
                                .font(.custom("AvenirNext-Regular", size: 15))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.9))
                                .cornerRadius(25)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .padding()
        }

        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: isGradientAnimating
                               ? [Color("1c3e35"), Color("99f2d1")]
                               : [Color("99f2d1"), Color("1c3e35")]),startPoint: .top,endPoint: .bottom)
        .edgesIgnoringSafeArea(.all)
        .animation(Animation.linear(duration: 5).repeatForever(autoreverses: true), value: isGradientAnimating)
        .onAppear { isGradientAnimating = true }
    }
    
    private func calculateWeight() {
        guard let earthWeight = Double(weightOnEarth), earthWeight > 0 else {
            calculatedWeights.removeAll()
            return
        }
        
        calculatedWeights = planets.map { (planet, gravity, _) in
            let planetWeight = earthWeight * gravity
            return (planet, planetWeight)
        }
    }
    
    private func calculateAge() {
        guard let earthAge = Double(ageOnEarth), earthAge > 0 else {
            calculatedAges.removeAll()
            return
        }
        
        calculatedAges = planets.map { (planet, _, yearLength) in
            let planetAge = earthAge / yearLength
            return (planet, planetAge)
        }
    }
    
    private func headerText(_ title: String, subtitle: String) -> some View {
        ZStack {
            if deviceType() == "iPhone" {
                VStack {
                    Text(title)
                        .font(.custom("AvenirNext-Regular", size: 35))
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    Text(subtitle)
                        .font(.custom("AvenirNext-Regular", size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
            }
            else if deviceType() == "iPad" {
                VStack {
                    Text(title)
                        .font(.custom("AvenirNext-Regular", size: 55))
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    Text(subtitle)
                        .font(.custom("AvenirNext-Regular", size: 36))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
            }
        }
    }
}

extension View {
    func textFieldStyle() -> some View {
        self
            .font(.custom("AvenirNext-Regular", size: deviceType() == "iPhone" ? 15 : 30))
            .keyboardType(.decimalPad)
            .scrollDismissesKeyboard(.interactively)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .padding()
            .foregroundColor(.primary)
            .accentColor(.blue)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    PlanetWeightCalculatorView()
}
