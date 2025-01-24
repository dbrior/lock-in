//
//  LandingPageView.swift
//  Locked In
//
//  Created by Daniel Brior on 1/13/25.
//

import SwiftUI
import FamilyControls

struct LandingPageView: View {
    let center = AuthorizationCenter.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Ready to lock in?")
                    .font(.largeTitle.lowercaseSmallCaps())
                    .onAppear {
                        Task {
                            do {
                                try await center.requestAuthorization(for: .individual)
                            } catch {
                                print("Failed to enroll Aniyah with error: \(error)")
                            }
                        }
                    }
                
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
