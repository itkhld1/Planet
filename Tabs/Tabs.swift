//
//  Tabs.swift
//  Planet
//
//  Created by itkhld on 2024-10-29.
//

//import SwiftUI
//
//struct Tabs: View {
//    @Binding var selectedTab: Int
//    let hapticTouch = UIImpactFeedbackGenerator(style: .medium)
//    
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            Group {
//                HomeView()
//                    .tabItem {
//                        Label("Solar System", systemImage: "gyroscope")
//                    }
//                    .tag(1)
//                
//                QuizView()
//                    .tabItem {
//                        Label("Quiz", systemImage: "brain.head.profile")
//                    }
//                    .tag(2)
//                
//                PlanetWeightCalculatorView()
//                    .tabItem {
//                        Label("Calculator", systemImage: "plusminus.circle")
//                    }
//                    .tag(3)
//                
//                SimulationView()
//                    .tabItem {
//                        Label("Simulation", systemImage: "atom")
//                    }
//                    .tag(4)
//            }
//            .toolbarBackground(.hidden, for: .tabBar)
//        }
//        .tint(.cyan)
//        .onChange(of: selectedTab) { _ in
//            hapticTouch.impactOccurred()
//        }
//    }
//}
//
//#Preview {
//    @State var previewSelectedTab: Int = 1
//    return Tabs(selectedTab: $previewSelectedTab)
//}


import SwiftUI

enum TabbedItems: Int, CaseIterable{
    case home = 0
    case favorite
    case chat
    case profile
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .favorite:
            return "Quiz"
        case .chat:
            return "Calculator"
        case .profile:
            return "Simulatior"
        }
    }
        
    var iconName: String {
        switch self {
        case .home:
            return "gyroscope"
        case .favorite:
            return "brain.head.profile.fill"
        case .chat:
            return "plusminus.circle.fill"
        case .profile:
            return "atom"
        }
    }
}

struct CustomTabBar: View {
    
    @State var selectedTab = 0
    let hapticTouch = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View  {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                QuizView()
                    .tag(1)
                PlanetWeightCalculatorView()
                    .tag(2)
                SimulationView()
                    .tag(3)
            }
            .onChange(of: selectedTab) { _ in
                hapticTouch.impactOccurred()
            }
            ZStack {
                HStack {
                    ForEach((TabbedItems.allCases), id: \.self) { item in
                        Button {
                            selectedTab = item.rawValue
                        } label: {
                            CustomTabItem(imageName: item.iconName, title: item.title, isActive: (selectedTab == item.rawValue))
                        }
                    }
                }
                .padding(6)
            }
            .frame(height: 50)
            .background(.gray.opacity(0.1))
            .cornerRadius(35)
            .padding(.horizontal, 30)
            //.offset(y: 15)
        }
    }
}

extension CustomTabBar {
    func CustomTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Spacer()
            Image(systemName: imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .cyan : .white.opacity(0.7))
                .frame(width: 20, height: 21)
            
            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .cyan : .gray)
            }
            Spacer()
        }
        .frame(width: isActive ? .infinity : 50, height: 35)
        .background(isActive ? .cyan.opacity(0.1) : .clear)
        .cornerRadius(30)
    }
}

#Preview {
    CustomTabBar(selectedTab: 0)
}
