//
//  TotalActivityView.swift
//  ActivityReport
//
//  Created by Daniel Brior on 1/12/25.
//

import SwiftUI
import Charts
import DeviceActivity
import FamilyControls
import ManagedSettings

struct ChartSlice {
    let name: String
    let timeInterval: TimeInterval
    let application: Application?
}

struct PiechartView: View {
    struct Configuration {
        let applicationUsages: [ApplicationUsage]
        
        static let loadingConfig = Configuration(applicationUsages: [])
    }
    
    let configuration: Configuration
    
    private var chartSlices: [ChartSlice] {
        let top10 = configuration.applicationUsages.prefix(10)
        
        if configuration.applicationUsages.count > 10 {
            let others = configuration.applicationUsages.suffix(configuration.applicationUsages.count - 10)
            
            let otherEntry = ChartSlice(
                name: "Other",
                timeInterval: others.reduce(0) { $0 + $1.timeInterval },
                application: nil
            )
            
            return Array(top10).map({
                ChartSlice(
                    name: $0.application.localizedDisplayName ?? "Unknown",
                    timeInterval: $0.timeInterval,
                    application: $0.application
                )
            }) + [otherEntry]
            
        } else {
            return Array(top10).map({
                ChartSlice(
                    name: $0.application.localizedDisplayName ?? "Unknown",
                    timeInterval: $0.timeInterval,
                    application: $0.application
                )
            })
        }
    }
    
    func formatTimeInterval(timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        return formatter.string(from: timeInterval) ?? "Unknown Time"
    }

    
    var body: some View {
        if configuration.applicationUsages.isEmpty {
            ProgressView()
        } else {
            VStack {
                Chart() {
                    ForEach(chartSlices, id: \.name) {item in
                        SectorMark(
                            angle: .value("Time", item.timeInterval),
                            innerRadius: .ratio(0.618),
                            angularInset: 0.5
                        )
                        .foregroundStyle(by: .value("Application", item.name))
                        .position(by: .value("TimeInterval", item.timeInterval))
                    }
                }
                .scaledToFit()
                .chartLegend(.hidden)
            }
            
            List() {
                ForEach(chartSlices, id: \.name) {item in
                    HStack {
                        if let applicationToken: ApplicationToken = item.application?.token {
                            Label(applicationToken)
                        } else {
                            Label("Other", systemImage: "ellipsis")
                        }
                        Spacer()
                        Text(formatTimeInterval(timeInterval: item.timeInterval))
                    }
                }
            }
        }
    }
}
