//
//  WalkthroughView.swift
//  Locked In
//
//  Created by Daniel Brior on 1/13/25.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct TrackedAppsCard : View {
    @Environment(AppModel.self) var appModel: AppModel
    @State var selection = FamilyActivitySelection()
    @State var isPresented = false
    
    var allSelectionCount: Int {
        return appModel.trackedCategories.count + appModel.trackedApplications.count + appModel.trackedDomains.count
    }
    
    var body : some View {
        VStack {
            HStack {
                Text("Tracked apps:")
                    .font(.headline)
                Spacer()
                Button {
                    isPresented = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .familyActivityPicker(isPresented: $isPresented, selection: $selection)
                .onChange(of: selection) {
                    appModel.saveFamilyPickerSelections(
                        newCategories: selection.categoryTokens,
                        newApplications: selection.applicationTokens,
                        newDomains: selection.webDomainTokens
                    )
                }
                .onAppear {
                    selection.categoryTokens = appModel.trackedCategories
                    selection.applicationTokens = appModel.trackedApplications
                    selection.webDomainTokens = appModel.trackedDomains
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 25) {
                    if allSelectionCount == 0 {
                        Color.clear
                            .frame(width: UIScreen.main.bounds.size.width*0.15, height: 50)
                        Text("No selected apps")
                        Color.clear
                            .frame(width: UIScreen.main.bounds.size.width*0.15, height: 50)
                    } else {
                        if allSelectionCount < 6 {
                            Color.clear
                                .frame(width: CGFloat(5-allSelectionCount)*25.0, height: 50)
                        }
                        
                        ForEach(Array(appModel.trackedCategories), id: \.self) { item in
                            Label(item)
                                .labelStyle(.iconOnly)
                                .scaleEffect(2)
                        }
                        ForEach(Array(appModel.trackedApplications), id: \.self) { item in
                            Label(item)
                                .labelStyle(.iconOnly)
                                .scaleEffect(2)
                        }
                        ForEach(Array(appModel.trackedDomains), id: \.self) { item in
                            Label(item)
                                .labelStyle(.iconOnly)
                                .scaleEffect(2)
                        }
                        
                        if allSelectionCount < 6 {
                            Color.clear
                                .frame(width: CGFloat(5-allSelectionCount)*25.0, height: 50)
                        }
                    }
                }
                .padding()
            }
            .defaultScrollAnchor(.center)
        }
//        .overlay() {
//            RoundedRectangle(cornerRadius: 5)
//                .fill(.clear)
//                .stroke(.secondary)
//        }
    }
}

struct LockAppsView: View {
    @Environment(AppModel.self) var appModel: AppModel
    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Lock In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            
            TrackedAppsCard()
                .padding(.horizontal)
                .padding(.top)
            
            Divider()
            
            Button("Hide walkthrough") {
                shouldShowOnboarding = false
            }
            .buttonStyle(.bordered)
            
            Spacer()
    
//
//            Button("Select Apps") { isPresented = true }
//            .familyActivityPicker(isPresented: $isPresented, selection: $selection)
//            .onChange(of: selection) {
//                applicationsToLock = selection.applicationTokens
//                showButton = selection.applicationTokens.count > 0
//            }
//            
//            Spacer()
//            
//            Text("New Applications to Lock:")
//            List {
//                ForEach(Array(applicationsToLock), id: \.self) { applicationToken in
//                    Label(applicationToken)
//                }
//            }
//            
//            Text("Currently Locked Applications:")
//            List {
//                ForEach(Array(appModel.lockedApplications), id: \.self) { applicationToken in
//                    Label(applicationToken)
//                }
//            }
//            
//            Spacer()
//            
//            HStack {
//                Spacer()
//                
//                Button {
//                    let allLocks = appModel.lockedApplications.union(applicationsToLock)
//                    
//                    appModel.lockedApplications = allLocks
//                    appModel.store.shield.applications = allLocks
//                    
//                    applicationsToLock = []
//                    
//                    shouldShowOnboarding = false
//                } label: {
//                    Text("Lock em down")
//                }
//                .buttonStyle(.borderedProminent)
//                
//                Spacer()
//                
//                Button {
//                    appModel.lockedApplications = []
//                    appModel.store.shield.applications = nil
//                } label: {
//                    Text("Clear locks")
//                }
//                .buttonStyle(.bordered)
//                Spacer()
//            }
        }
//        Spacer()
    }
}

#Preview {
    var previewModel: AppModel = AppModel()
    
    LockAppsView()
        .padding()
        .environment(previewModel)
}
