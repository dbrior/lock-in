//
//  DeviceActivityMonitorExtension.swift
//  ActivityMonitor
//
//  Created by Daniel Brior on 1/22/25.
//

import DeviceActivity
import ManagedSettings
import Foundation
import os

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        let logger = Logger()
        logger.log("Interval start")
        
        let appModel: AppModel = AppModel.loadModelFromStorage() ?? AppModel()
        
        logger.log("Found \(appModel.trackedApplications.count) applications on model")
        logger.log("Found \(appModel.trackedCategories.count) categories on model")
        logger.log("Found \(appModel.trackedDomains.count) domains on model")
        
        appModel.store.shield.applications = appModel.trackedApplications
//            appModel.store.shield. = appModel.trackedCategories
        appModel.store.shield.webDomains = appModel.trackedDomains
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        let logger = Logger()
        logger.log("Interval end")
        
        let appModel: AppModel = AppModel.loadModelFromStorage() ?? AppModel()
        
        logger.log("Found \(appModel.trackedApplications.count) applications on model")
        logger.log("Found \(appModel.trackedCategories.count) categories on model")
        logger.log("Found \(appModel.trackedDomains.count) domains on model")
        
        appModel.store.shield.applications = nil
        appModel.store.shield.applicationCategories = nil
        appModel.store.shield.webDomains = nil
        
        logger.log("Applications unlocked")
        DeviceActivityCenter().stopMonitoring([activity])
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Handle the event reaching its threshold.
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Handle the warning before the interval starts.
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        // Handle the warning before the interval ends.
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        
        // Handle the warning before the event reaches its threshold.
    }
}
