//
//  AppModel.swift
//  Locked In
//
//  Created by Daniel Brior on 1/22/25.
//

import Observation
import ManagedSettings
import Foundation

extension ManagedSettingsStore.Name {
    static let lockedIn = Self("lockedIn")
}

extension UserDefaults {
    static let group = UserDefaults(suiteName: "group.Locked-In")
}

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
    
    var store = ManagedSettingsStore(named: .lockedIn)
    let domain = Bundle.main.bundleIdentifier!
    
    var trackedCategories: Set<ActivityCategoryToken>
    var trackedApplications: Set<ApplicationToken>
    var trackedDomains: Set<WebDomainToken>
    
    func saveFamilyPickerSelections(newCategories: Set<ActivityCategoryToken>, newApplications: Set<ApplicationToken>, newDomains: Set<WebDomainToken>) {
        trackedCategories = newCategories
        trackedApplications = newApplications
        trackedDomains = newDomains
        
        print("Setting \(trackedCategories.count) categories")
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.group!.set(encoded, forKey: "FamilyPickerSelections")
        }
    }
    
    static func loadModelFromStorage() -> AppModel? {
        if let savedAppModel = UserDefaults.group!.object(forKey: "FamilyPickerSelections") as? Data {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(AppModel.self, from: savedAppModel) {
                return decoded
            } else {
                print("AppModel decode error")
                return nil
            }
        } else {
            print("AppModel not saved")
            return nil
        }
    }
}

extension AppModel {
    static var sampleData: AppModel = AppModel()
}
