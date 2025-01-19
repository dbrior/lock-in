//
//  ActivityReportView.swift
//  Locked In
//
//  Created by Daniel Brior on 1/13/25.
//

import SwiftUI
import DeviceActivity

extension DeviceActivityReport.Context {
    static let pieChart = Self("pieChart")
}

struct ActivityReportView: View {
    // Activity Report
    @State private var context: DeviceActivityReport.Context = .pieChart
    @State private var filter: DeviceActivityFilter = DeviceActivityFilter(segment: .daily(during: DateInterval(start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, end: Date())))
    
    @State var isLoading: Bool = true
    
    var body: some View {
        VStack {
            Text("Your Screentime")
                .font(.largeTitle)
                .fontWeight(.bold)
            ZStack {
                if isLoading {
                    ProgressView()
                }
                DeviceActivityReport(context, filter: filter)
                    .task {
                        do {
                            try await Task.sleep(for: .seconds(2))
                            isLoading = false
                        } catch {
                            print("Error: \(error)")
                            isLoading = false
                        }
                    }
            }
            NavigationLink("I can do better", destination: LockAppsView())
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ActivityReportView()
}
