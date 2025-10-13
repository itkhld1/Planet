//
//  SwiftUIView.swift
//  Planet
//
//  Created by itkhld on 2024-12-01.
//

import SwiftUI

struct AppInstruction: View {
    @State private var showInstructions: Bool = true
    @State private var selectedTab: Int = 0
    @State private var showIcon = false
    @State private var showWelcomeText = false
    @State private var showInteractiveFeatureText = false
    @State private var showInfoText = false
    @State private var showButton = false
    @State private var showInfooo = false
    
    @AppStorage("AppInstruction")
    var AppInstruction: Bool = false
    
    var body: some View {
        ZStack {
            //Tabs(selectedTab: $selectedTab)
            CustomTabBar(selectedTab: selectedTab)
            
            if deviceType() == "iPhone" {
                if showInstructions {
                    VStack(spacing: 16) {

                        if showIcon {
                            Image("Logo")
                                .resizable()
                                .frame(width: 175, height: 100)
                                .shadow(color: .blue.opacity(0.9), radius: 20)
                        }
                        
                        if showWelcomeText {
                            Text("Welcome to ***Planet*** App!")
                                .font(.custom("AvenirNext-Regular", size: 25))
                                .fontWeight(.bold)
                                .padding()
                                .foregroundColor(.white)
                                .transition(.move(edge: .bottom))
                        }
                        
                        if showInteractiveFeatureText {
                            Text("This app is your ultimate guide to exploring our fascinating solar system! Designed especially for **CHILDREN**, it provides a fun and engaging environment to learn about the planets with interactive 3D models and animations.")
                                .font(.custom("AvenirNext-Regular", size: 12))
                                .multilineTextAlignment(.center)
                                .padding()
                                .foregroundColor(.white)
                                .transition(.move(edge: .bottom))
                        }
                        
                        if showInfoText {
                            HStack {
                                
                                Button(action: {
                                    showInfooo.toggle()
                                }, label: {
                                    Image(systemName: "info.circle")
                                })
                                .sheet(isPresented: $showInfooo, content: {
                                    UserGuideView()
                                })
                                Text("Use this button to learn more about the app.")
                            }
                            .font(.custom("AvenirNext-Regular", size: 14))
                            .multilineTextAlignment(.center)
                            .bold()
                            .padding()
                            .foregroundColor(.gray)
                            .transition(.move(edge: .bottom))
                        }
                        
                        if showButton {
                            Button {
                                showInstructions = false
                                selectedTab = 1
                            } label: {
                                Text("Let's Explore!")
                                    .font(.custom("AvenirNext-Regular", size: 19))
                                    .padding()
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .shadow(color: .blue.opacity(0.5), radius: 20)

                            }
                            .transition(.scale)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        animateTextAppearance()
                    }
                    VStack(spacing: 6) {
                        Text("Made By ***Itkhld***")
                            .font(.custom("AvenirNext-Regular", size: 10))
                        Text("Designed for iPhones")
                            .font(.custom("AvenirNext-Regular", size: 9))
                    }
                    .foregroundColor(.gray)
                    .padding(.top, 700)
                }
            }
            else if deviceType() == "iPad" {
                if showInstructions {
                    VStack(spacing: 16) {

                        if showIcon {
                            Image("Logo")
                                .resizable()
                                .frame(width: 295, height: 180)
                                .shadow(color: .blue.opacity(0.9), radius: 20)
                                .padding()
                        }
                        
                        if showWelcomeText {
                            Text("Welcome to ***Planet*** App!")
                                .font(.custom("AvenirNext-Regular", size: 35))
                                .fontWeight(.bold)
                                .padding()
                                .foregroundColor(.white)
                                .transition(.move(edge: .bottom))
                        }
                        
                        if showInteractiveFeatureText {
                            Text("Install the app on a physical ***iPhone 13 Pro*** or higher to be able to use the 3D interactive feature & enjoy the best experience.")
                                .font(.custom("AvenirNext-Regular", size: 20))
                                .padding()
                                .foregroundColor(.white)
                                .transition(.move(edge: .bottom))
                        }
                        
                        if showInfoText {
                            HStack {
                                Image(systemName: "info.circle")
                                Text("Use the button to learn more about the app.")
                            }
                            .font(.custom("AvenirNext-Regular", size: 18))
                            .multilineTextAlignment(.center)
                            .bold()
                            .padding(20)
                            .foregroundColor(.gray)
                            .transition(.move(edge: .bottom))
                        }
                        
                        if showButton {
                            Button {
                                showInstructions = false
                                selectedTab = 1
                            } label: {
                                Text("Let's Explore!")
                                    .font(.custom("AvenirNext-Regular", size: 25))
                                    .padding()
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .shadow(color: .blue.opacity(0.5), radius: 20)

                            }
                            .transition(.scale)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        animateTextAppearance()
                    }
                    
                    VStack(spacing: 6) {
                        Text("Made By ***Itkhld***")
                            .font(.custom("AvenirNext-Regular", size: 13))
                        Text("Designed for iPhones")
                            .font(.custom("AvenirNext-Regular", size: 12))
                    }
                    .foregroundColor(.gray)
                    .padding(.top, 1200)
                }
            }
        }.onAppear(perform: {
            UserDefaults.standard.AppInstruction = true
        })
    }
    
    
    private func animateTextAppearance() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                showIcon = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showWelcomeText = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                showInteractiveFeatureText = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation {
                showInfoText = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            withAnimation {
                showButton = true
            }
        }
    }
}


#Preview {
    AppInstruction()
}
