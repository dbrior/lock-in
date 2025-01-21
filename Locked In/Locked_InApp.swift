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
class AppModel: Codable {
    // ------ Coding ------
    enum CodingKeys : CodingKey {
        case trackedCategories, trackedApplications, trackedDomains
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(trackedCategories, forKey: .trackedCategories)
        try container.encode(trackedApplications, forKey: .trackedApplications)
        try container.encode(trackedDomains, forKey: .trackedDomains)
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        trackedCategories = try container.decode(Set<ActivityCategoryToken>.self, forKey: .trackedCategories)
        trackedApplications = try container.decode(Set<ApplicationToken>.self, forKey: .trackedApplications)
        trackedDomains = try container.decode(Set<WebDomainToken>.self, forKey: .trackedDomains)
    }
    // --------------------
    
    init() {
        trackedCategories = []
        trackedApplications = []
        trackedDomains = []
    }
    
    var store = ManagedSettingsStore()
    let domain = Bundle.main.bundleIdentifier!
    
    var trackedCategories: Set<ActivityCategoryToken>
    var trackedApplications: Set<ApplicationToken>
    var trackedDomains: Set<WebDomainToken>
    
    func saveFamilyPickerSelections(newCategories: Set<ActivityCategoryToken>, newApplications: Set<ApplicationToken>, newDomains: Set<WebDomainToken>) {
        trackedCategories = newCategories
        trackedApplications = newApplications
        trackedDomains = newDomains
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: "FamilyPickerSelections")
        }
    }
}

extension AppModel {
    static var sampleData: AppModel = AppModel()
}

@main
struct Locked_In: App {
    @State private var appModel: AppModel
    
    init() {
        if let savedAppModel = UserDefaults.standard.object(forKey: "FamilyPickerSelections") as? Data {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(AppModel.self, from: savedAppModel) {
                appModel = decoded
            } else {
                print("AppModel decode error")
                appModel = AppModel()
            }
        } else {
            print("AppModel not saved")
            appModel = AppModel()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environment(appModel)
        }
    }
}
