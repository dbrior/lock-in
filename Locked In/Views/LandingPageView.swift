//
//  LandingPageView.swift
//  Locked In
//
//  Created by Daniel Brior on 1/13/25.
//

import SwiftUI

struct LandingPageView: View {
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Ready to lock in?")
                    .font(.largeTitle.lowercaseSmallCaps())
                
                Spacer()
                
                Image(systemName: "lock")
                    .foregroundColor(.blue)
                    .font(.system(size: 150, weight: .light))
                
                Spacer()
                
//                NavigationLink("Hell Yeah", destination: ActivityReportView())
//                .buttonStyle(.borderedProminent)
                
//                Spacer()
            }
            
        }
        
    }
}

#Preview {
    LandingPageView()
}
