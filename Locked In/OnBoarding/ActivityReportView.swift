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
    @State var isLoading: Bool = true
    @State var dayRange: Int = 7
    
    // Activity Report
    @State private var context: DeviceActivityReport.Context = .pieChart
    private var dateInterval: DateInterval {
        return DateInterval(start: Calendar.current.date(byAdding: .day, value: -dayRange, to: Date())!, end: Date())
    }
    private var filter: DeviceActivityFilter {
        return DeviceActivityFilter(
            segment: .daily(
                during: dateInterval
            )
        )
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Screentime")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Picker("", selection: $dayRange) {
                Text("1 Day")
                    .tag(1)
                Text("7 Days")
                    .tag(7)
                Text("30 Days")
                    .tag(30)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            
            ZStack {
//                if isLoading {
//                    ProgressView()
//                }
                DeviceActivityReport(context, filter: filter)
//                    .padding()
//                    .task {
//                        do {
//                            try await Task.sleep(for: .seconds(2))
//                            isLoading = false
//                        } catch {
//                            print("Error: \(error)")
//                            isLoading = false
//                        }
//                    }
            }
//            NavigationLink("I can do better", destination: LockAppsView())
//            .buttonStyle(.borderedProminent)
        }
//        .padding()
    }
}

#Preview {
    ActivityReportView()
}
