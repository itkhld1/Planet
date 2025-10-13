//
//  PlanetDetailInfoView.swift
//  Planet
//
//  Created by itkhld on 2024-10-04.
//

import SwiftUI

struct PlanetsReadmoreView: View {
    
    let planetName: String
    
    var body: some View {
        
        ZStack {
            Color("ReadMore")
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                Text(planetName)
                    .padding()
                    .font(.custom("AvenirNext-Regular", size: 32))
                    .foregroundColor(Color("ReadMoreFontColor"))
                    .padding(.bottom, 5)
                
                Text(PlanetDetails.getDescription(for: planetName))
                    .font(.custom("AvenirNext-Regular", size: 15))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color("ReadMoreFontColor"))
                    .padding()
            }
        }
    }
}

#Preview {
    PlanetsReadmoreView(planetName: "Earth")
}
