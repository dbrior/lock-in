//
//  WalkthroughView.swift
//  Locked In
//
//  Created by Daniel Brior on 1/13/25.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct LockAppsView: View {
    @Environment(AppModel.self) var appModel: AppModel
    
    @State var applicationsToLock: Set<ApplicationToken> = []
    
    @State var selection = FamilyActivitySelection()
    @State var isPresented = false
    
    @State var showButton: Bool = false
    
    var body: some View {
        VStack {
            Text("Let's lock it down")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button("Select Apps") { isPresented = true }
            .familyActivityPicker(isPresented: $isPresented, selection: $selection)
            .onChange(of: selection) {
                applicationsToLock = selection.applicationTokens
                showButton = selection.applicationTokens.count > 0
            }
            
            Spacer()
            
            Text("New Applications to Lock:")
            List {
                ForEach(Array(applicationsToLock), id: \.self) { applicationToken in
                    Label(applicationToken)
                }
            }
            
            Text("Currently Locked Applications:")
            List {
                ForEach(Array(appModel.lockedApplications), id: \.self) { applicationToken in
                    Label(applicationToken)
                }
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    let allLocks = appModel.lockedApplications.union(applicationsToLock)
                    
                    appModel.lockedApplications = allLocks
                    appModel.store.shield.applications = allLocks
                    
                    applicationsToLock = []
                } label: {
                    Text("Lock em down")
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                Button {
                    appModel.lockedApplications = []
                    appModel.store.shield.applications = nil
                } label: {
                    Text("Clear locks")
                }
                .buttonStyle(.bordered)
                Spacer()
            }
            
            
                
//            NavigationLink("I'm ready", destination: LockAppsView())
//                .buttonStyle(.borderedProminent)
//                .disabled(!showButton)
            
        }
        .padding()
    }
}

#Preview {
    LockAppsView()
}
