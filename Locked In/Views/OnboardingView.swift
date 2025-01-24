//
//  OnboardingView.swift
//  Locked In
//
//  Created by Daniel Brior on 1/19/25.
//

import SwiftUI

extension AnyTransition {
    static var slideReverse: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading))}
}

struct OnboardingButton : View {
    let text: String
    @Binding var currTabIdx: Int
    
    var body: some View {
        Button(text) {
            withAnimation(.easeInOut(duration: 0.5)) {
                currTabIdx += 1
            }
        }
        .buttonStyle(.borderedProminent)
    }
}

struct OnboardingView: View {
    @State var tabSelection: Int = 0
    
    var body: some View {
        switch(tabSelection) {
        case 0:
            VStack {
                LandingPageView()
                Spacer()
                OnboardingButton(text: "Hell Yeah", currTabIdx: $tabSelection)
            }
            .transition(.slideReverse)
        case 1:
            VStack {
                ActivityReportView()
                Spacer()
                OnboardingButton(text: "I can do better", currTabIdx: $tabSelection)
            }
            .transition(.slideReverse)
        case 2:
            VStack {
                LockAppsView()
            }
            .tabItem {}
            .tag(2)
            .transition(.slideReverse)
        default:
            Text("All Set!")
        }
        
        
        
//        TabView(selection: $tabSelection) {
//            VStack {
//                LandingPageView()
//                Spacer()
//                Button("Hell Yeah") {
//                    withAnimation(.easeInOut(duration: 1)) {
//                        tabSelection += 1
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//            }
//            .tabItem {}
//            .tag(0)
//            .transition(.slide)
//            
//            
//            VStack {
//                ActivityReportView()
//                Spacer()
//                Button("I can do better") {
//                    withAnimation(.easeInOut(duration: 1)) {
//                        tabSelection += 1
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//            }
//            .tabItem {}
//            .tag(1)
//            .transition(.slide)
//            
//            VStack {
//                LockAppsView()
//            }
//            .tabItem {}
//            .tag(2)
//            .transition(.slide)
//        }
//        .transition(.slide)
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//        .animation(.easeInOut(duration: 1), value: tabSelection)
//        .transition(.slide)
//        .animation(.easeInOut(duration: 1.0), value: tabSelection)
//        .transition(.slide)
    }
}

#Preview {
    OnboardingView()
}
