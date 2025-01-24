//
//  ContentView.swift
//  Locked In
//
//  Created by Daniel Brior on 1/19/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding: Bool = true
    @Environment(\.modelContext) private var context
    
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
            
            SessionHistoryView()
                .tabItem {
                    Label("Session History", systemImage: "chart.bar.xaxis")
                }
            
//            DebugControlsView()
//                .tabItem {
//                    Label("Settings", systemImage: "gear")
//                }
        }
        .fullScreenCover(isPresented: $shouldShowOnboarding) {
            SplashScreen()
        }
        .padding()
        .onAppear {
//            // Clear DB
//            do {
//                try context.delete(model: LockSession.self)
//            } catch {
//                print("Failed to clear all Country and City data.")
//            }
            //            shouldShowOnboarding = true

            
            // populate db
            for idx in 0..<60 {
                let startDate: Date = Calendar.current.date(byAdding: .day, value: -idx, to: Date())!
                let lockTime: TimeInterval = TimeInterval(Double.random(in: 1...12) * 3600)
                let endDate: Date = startDate.addingTimeInterval(lockTime)
                
                let newEntry: LockSession = LockSession(startDate: startDate, proposedEndDate: endDate, endDate: endDate, lockedApplications: [], lockedCategories: [], lockedDomains: [])
                
                context.insert(newEntry)
            }
            
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
//            appearance.stackedLayoutAppearance.normal.iconColor = .gray
//            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
//            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.black)
//            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(Color.black)]
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    var previewModel: AppModel = AppModel()
    
    ContentView()
        .environment(previewModel)
}
