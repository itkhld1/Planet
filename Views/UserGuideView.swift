//
//  UserGuideView.swift
//  Planet
//
//  Created by itkhld on 2024-11-03.
//

import SwiftUI

struct UserGuideView: View {
    
    var body: some View {
        
        VStack {
            VStack(spacing: 6){
                Text("About this app")
                    .font(.caption).fontWeight(.bold)
                    .foregroundColor(.secondary)
                Text("Planets Solar System")
                    .font(.title2).fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                Text("This app is your ultimate guide to exploring our fascinating solar system! Designed especially for **CHILDREN**, it provides a fun and engaging environment to learn about the planets with interactive 3D models and animations.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 35) {
                    ScrollViewComponents(
                        NFSymbol: "gyroscope",
                        text: "**Solar System Tab**: Check out our solar system with each planet in its orbit. You can zoom in or out the solar system and you can put in every place you want. ***Explore Each Planet:*** Tap any planet to open a pop-up with a picture and a short description. ***Read More:*** Learn even more about the planet by tapping ***Read More.*** ***3D Exploration:*** Tap ***Explore planet 3D*** to see the planet in 3D. ***In this view:*** ***Zoom In/Out:*** Use the zoom buttons to take a closer look or get a full view! ***Show Planet:*** Tap to display the planet’s 3D model for an interactive experience."
                    )
                    
                    ScrollViewComponents(
                        NFSymbol: "brain.head.profile.fill",
                        text: "**Quiz Tab:** Answer 10 random questions about the solar system after exploring the solar system. Each quiz is different, so you can keep learning with new questions!"
                    )
                    
                    ScrollViewComponents(
                        NFSymbol: "plusminus.circle.fill",
                        text: "**Calculator Tab:** Enter your weight or age on Earth, and see how much you'd weigh and what is you age on any other planet!"
                    )
                    
                    ScrollViewComponents(
                        NFSymbol: "atom",
                        text: "**Simulation Tab:** Explore the solar system with a simulation of the planets' orbits. Tap any planet to see a 3D model of its orbit."
                    )
                    
                    ScrollViewComponents(
                        NFSymbol: "rotate.3d.fill",
                        text: "**Solar System 3D On the Top Left:** Dive into a full 3D model of the entire solar system! Move around to see the planets, their positions, and how they orbit the Sun."
                    )
                    
                    ScrollViewComponents(
                        NFSymbol: "person.crop.circle",
                        text: "I am ***Ahmad Khaled Samim***, a self-taught Swift developer with a passion for iOS development. I learned Swift through online courses on YouTube and other educational platforms. I have developed several apps, some of which are available on my GitHub, while others remain unpublished. Feel free to explore my work on [GitHub!](https://github.com/itkhld1)"
                    )
                    
                    ScrollViewComponents(
                        NFSymbol: "swift",
                        text: "**This app created as a submission for the Apple WWDC25 Swift Student Challenge.**"
                    )
                }
                .padding(20)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

struct ScrollViewComponents: View {
    var NFSymbol: String
    var text: String
    
    var body: some View {
        HStack(alignment: .top){
            Image(systemName: NFSymbol)
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.accentColor)
                .frame(width: 20, height: 20)
                .padding(10)
                .background(
                    Color.accentColor.opacity(0.1)
                        .cornerRadius(10)
                )
                .padding(.trailing, 20)
            Text(try! AttributedString(markdown: text))
                .font(.footnote)
                .lineSpacing(1.1)
        }
    }
}

#Preview {
    UserGuideView()
}
