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
    
    let domain = Bundle.main.bundleIdentifier!
    
    init() {
        self.lockedApplications = self.store.shield.applications ?? []
    }
}

extension AppModel {
    static var sampleData: AppModel = AppModel()
}

@main
struct Locked_In: App {
    @State private var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environment(appModel)
        }
    }
}
