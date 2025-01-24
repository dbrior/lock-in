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

struct ChartSlice : Equatable {
    let name: String
    let timeInterval: TimeInterval
    let application: Application?
    let id = UUID()
    
    init(name: String, timeInterval: TimeInterval, application: Application?) {
        self.name = name
        self.timeInterval = timeInterval
        self.application = application
    }
    
    static func == (lhs: ChartSlice, rhs: ChartSlice) -> Bool {
        return (
            lhs.name == rhs.name &&
            lhs.timeInterval == rhs.timeInterval &&
            lhs.application == rhs.application
        )
    }

}

struct PiechartView: View {
    struct Configuration {
        let applicationUsages: [ApplicationUsage]
        
        static let loadingConfig = Configuration(applicationUsages: [])
    }
    
    let configuration: Configuration
    
    private var chartSlices: [ChartSlice] {
        let sliceCount = 7
        let topN = configuration.applicationUsages.prefix(sliceCount)
        
        if configuration.applicationUsages.count > sliceCount {
            let others = configuration.applicationUsages.suffix(configuration.applicationUsages.count - 10)
            
            let otherEntry = ChartSlice(
                name: "Other",
                timeInterval: others.reduce(0) { $0 + $1.timeInterval },
                application: nil
            )
            
            return Array(topN).map({
                ChartSlice(
                    name: $0.application.localizedDisplayName ?? "Unknown",
                    timeInterval: $0.timeInterval,
                    application: $0.application
                )
            }) + [otherEntry]
            
        } else {
            return Array(topN).map({
                ChartSlice(
                    name: $0.application.localizedDisplayName ?? "Unknown",
                    timeInterval: $0.timeInterval,
                    application: $0.application
                )
            })
        }
    }
    
    var initPlotData: [ChartSlice] {
        return chartSlices.map {
            ChartSlice(name: $0.name, timeInterval: TimeInterval(0), application: $0.application)
        }
    }
    
    @State var plotData: [ChartSlice] = []
    @State var rawChartSelection: TimeInterval?
    var chartSelection: ChartSlice? {
        if rawChartSelection == nil {
            return nil
        }
        
        var accumTotal = 0.0
        for chartSlice in chartSlices {
            accumTotal += Double(chartSlice.timeInterval)
            if rawChartSelection! <= accumTotal {
                return chartSlice
            }
        }
        
        return nil
    }
    @State var shownChartSelection: ChartSlice?
    
    var totalTime: TimeInterval {
        return chartSlices.reduce(0) { $0 + $1.timeInterval }
    }
    
    var centerTextMain: String {
        return chartSelection == nil ? "Total" : chartSelection!.name
    }
    
    var centerTextSub: String {
        return chartSelection == nil ? formatTimeInterval(timeInterval: totalTime) : formatTimeInterval(timeInterval: chartSelection!.timeInterval)
    }
    
    var sliceColors: [Color] = [
        .blue,
        .green,
        .orange,
        .red,
        .purple,
        .yellow,
        .pink,
        .teal,
        .brown,
        .gray
    ]
    
//    @State var plotData: [ChartSlice] = Array(
//        repeating: ChartSlice(name:"", timeInterval: TimeInterval(0), application: nil),
//        count: 10
//    )
    
    func formatTimeInterval(timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        return formatter.string(from: timeInterval) ?? "Unknown Time"
    }
    
    private func colorForCategory(_ category: String) -> Color {
        // Use a consistent method to assign colors
        let hashValue = category.hash
        let hue = Double(abs(hashValue % 360)) / 360.0
        return Color(hue: hue, saturation: 0.8, brightness: 0.8)
    }

    
    var body: some View {
        if configuration.applicationUsages.isEmpty {
            ProgressView()
        } else {
            VStack {
                Chart(0..<plotData.count, id: \.self) { idx in
                    let item = plotData[idx]
                    
                    var sliceColor = sliceColors[idx % sliceColors.count]
                    
                    if item.name != "Other" {
                        SectorMark(
                            angle: .value("Time", item.timeInterval),
                            innerRadius: .ratio(0.618),
                            outerRadius: shownChartSelection == item || shownChartSelection == nil ? .ratio(1) : .ratio(0.9),
                            angularInset: 0.25
                        )
                        .opacity(shownChartSelection == item || shownChartSelection == nil ? 1.0 : 0.75)
                        .cornerRadius(5)
                        .foregroundStyle(sliceColor)
                    } else {
                        SectorMark(
                            angle: .value("Time", item.timeInterval),
                            innerRadius: .ratio(0.618),
                            outerRadius: shownChartSelection == item || shownChartSelection == nil ? .ratio(1) : .ratio(0.9),
                            angularInset: 0.25
                        )
                        .opacity(shownChartSelection == item || shownChartSelection == nil ? 1.0 : 0.75)
                        .cornerRadius(5)
                        .foregroundStyle(.gray)
                    }
                    
                }
                // Styling
                .scaledToFit()
                .chartLegend(.hidden)
                .padding(.top)
                // Animations
                .onAppear {
                    plotData = initPlotData
                    withAnimation(.easeInOut(duration: 2)) {
                        plotData = chartSlices
                    }
                }
                .onChange(of: chartSlices) {
                    withAnimation(.easeInOut(duration: 1)) {
                        plotData = chartSlices
                    }
                }
                // Selection
                .chartAngleSelection(value: $rawChartSelection)
                .onChange(of: chartSelection) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        shownChartSelection = chartSelection
                    }
                }
                // Center Text
                .chartBackground { chartProxy in
                    GeometryReader { geometry in
                        if let anchor = chartProxy.plotFrame {
                            let frame = geometry[anchor]
                            
                            VStack {
                                Text(centerTextMain)
                                    .fontWeight(.bold)
                                Text(centerTextSub)
                            }
                            .position(x: frame.midX, y: frame.midY)
                        }
                    }
                }
                
                Spacer()
                Spacer()
                
                List() {
                    ForEach(0..<plotData.count, id: \.self) { idx in
                        let item = plotData[idx]
                        
                        let sliceColor = sliceColors[idx % sliceColors.count]
                        HStack {
                            if let applicationToken: ApplicationToken = item.application?.token {
                                Label(applicationToken)
                            } else {
                                Label("Other", systemImage: "ellipsis")
                            }
                            Spacer()
                            Text(formatTimeInterval(timeInterval: item.timeInterval))
                            Circle()
                                .foregroundStyle(item.name == "Other" ? .gray : sliceColor)
                                .frame(width: 10, height: 10)
                                .padding(.leading)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}
