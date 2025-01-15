//
//  Locked_InApp.swift
//  Locked In
//
//  Created by Daniel Brior on 1/12/25.
//

import SwiftUI
import Observation
import DeviceActivity
import ManagedSettings

@Observable 
class AppModel {
    var store = ManagedSettingsStore()
    var lockedApplications: Set<ApplicationToken> = []
    var applicationActivity: [Application:TimeInterval] = [:]
}

extension AppModel {
    static var sampleData: AppModel = AppModel()
}

@main
struct Locked_In: App {
    @State private var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            LandingPageView()
                .onAppear {
                    appModel.lockedApplications = appModel.store.shield.applications ?? []
                }
                .environment(appModel)
        }
    }
}
