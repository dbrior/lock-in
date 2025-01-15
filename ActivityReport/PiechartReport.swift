//
//  TotalActivityReport.swift
//  ActivityReport
//
//  Created by Daniel Brior on 1/12/25.
//

import DeviceActivity
import ManagedSettings
import SwiftUI

extension DeviceActivityReport.Context {
    static let pieChart = Self("pieChart")
}

struct PiechartReport: DeviceActivityReportScene {
    // Define which context your scene will represent.
    let context: DeviceActivityReport.Context = .pieChart
    let content: (PiechartView.Configuration) -> PiechartView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> PiechartView.Configuration {
        
        var applcaitionUsages: [Application: TimeInterval] = [:]
            
        // Iterate through the nested async sequences
        for await segment in data.flatMap({ $0.activitySegments }) {
            for await category in segment.categories {
                for await applicationActivity in category.applications {
                    applcaitionUsages[applicationActivity.application, default: 0] += applicationActivity.totalActivityDuration
                }
            }
        }
        
        var applicationUsagesArray: [ApplicationUsage] = []
        
        for (application, timeInterval) in applcaitionUsages {
            applicationUsagesArray.append(ApplicationUsage(application: application, timeInterval: timeInterval))
        }
        
        applicationUsagesArray.sort(by: {$0.timeInterval > $1.timeInterval})
        
        return PiechartView.Configuration(applicationUsages: applicationUsagesArray)
    }
}
