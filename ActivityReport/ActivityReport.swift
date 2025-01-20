//
//  ActivityReport.swift
//  ActivityReport
//
//  Created by Daniel Brior on 1/12/25.
//

import DeviceActivity
import SwiftUI

@main
struct ActivityReport: DeviceActivityReportExtension {
    
    var body: some DeviceActivityReportScene {
        TotalActivityReport { configuration in
            TotalActivityView(totalActivity: configuration)
        }
        PiechartReport { configuration in
            PiechartView(configuration: configuration)
        }
    }
}
