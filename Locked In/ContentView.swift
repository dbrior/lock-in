//
//  ContentView.swift
//  Locked In
//
//  Created by Daniel Brior on 1/19/25.
//

import SwiftUI
import ManagedSettings

struct ContentView: View {
    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding: Bool = true
    @Environment(\.modelContext) private var context
    @Environment(AppModel.self) var appModel: AppModel
    
    @State var selectedTabIdx: Int = 1
    
    var body: some View {
        TabView(selection: $selectedTabIdx) {
            ActivityReportView()
                .tabItem {
                    Label("Screen Time", systemImage: "display")
                }
                .tag(0)
            
            LockAppsView()
                .tabItem {
                    Label("Lock", systemImage: "lock.fill")
                }
                .tag(1)
            
            SessionHistoryView()
                .tabItem {
                    Label("Session History", systemImage: "chart.bar.xaxis")
                }
                .tag(2)
        }
        .fullScreenCover(isPresented: $shouldShowOnboarding) {
            SplashScreen()
        }
        .padding()
        .onAppear {
//            // Clear UserDefaults
//            let domain = Bundle.main.bundleIdentifier!
//            UserDefaults.standard.removePersistentDomain(forName: domain)
            
//            // Clear DB
//            do {
//                try context.delete(model: LockSession.self)
//            } catch {
//                print("Failed to clear all Country and City data.")
//            }
            
//            // Onboarding screen
//            shouldShowOnboarding = true

            
//            // populate db
//            for idx in 0..<60 {
//                // Random start time on day from 00:00 to 12:00
//                var startDate: Date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -idx, to: Date())!)
//                startDate += TimeInterval(Double.random(in: 1...12) * 3600)
//                
//                // Lock duration between 15 min and 9 hours
//                // (Random 0 to 8 hours) + (Random 15 to 60 minutes)
//                let lockTime: TimeInterval = TimeInterval(Int.random(in: 0...8) * 3600) + TimeInterval(Int.random(in: 1...4) * 60 * 15)
//                let endDate: Date = startDate.addingTimeInterval(lockTime)
//                
//                // Proposed end date = lock time for even days, else lock time + 1 hr for odd days
//                // i.e half successful vs unsuccesful sessions
//                let proposedEndDate: Date = endDate.addingTimeInterval(idx % 2 == 0 ? TimeInterval(0) : TimeInterval(60*60))
//                
//                
//                func generateRandomApplicationTokens() -> Set<ApplicationToken> {
//                    let tokens = Array(appModel.trackedApplications)
//                    let n = Int.random(in: 3...tokens.count)
//                    
//                
//                    var uniqueTokens = Set<ApplicationToken>()
//                    while uniqueTokens.count < n {
//                        let randomIdx = Int.random(in: 0..<tokens.count)
//                        uniqueTokens.insert(tokens[randomIdx])
//                    }
//                    
//                    return uniqueTokens
//                }
//                let sessionLockedApplications: Set<ApplicationToken> = generateRandomApplicationTokens()
//                
//                let newEntry: LockSession = LockSession(startDate: startDate, proposedEndDate: proposedEndDate, endDate: endDate, lockedApplications: sessionLockedApplications, lockedCategories: [], lockedDomains: [])
//                
//                context.insert(newEntry)
//            }
            
            
            // Force dark mode
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
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
