//
//  ContentView.swift
//  Locked In
//
//  Created by Daniel Brior on 1/19/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding: Bool = true
    
    var body: some View {
        TabView {
            ActivityReportView()
                .tabItem {
                    Label("Screen Time", systemImage: "display")
                }
            
            LockAppsView()
                .tabItem {
                    Label("Lock", systemImage: "lock.fill")
                }
            
            DebugControlsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .fullScreenCover(isPresented: $shouldShowOnboarding) {
            OnboardingView()
        }
        .padding()
    }
}

#Preview {
    var previewModel: AppModel = AppModel()
    
    ContentView()
        .environment(previewModel)
}
