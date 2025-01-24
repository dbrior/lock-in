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
    let calendar = Calendar.current
    
    @State var isLoading: Bool = true
    @State var selectedDateStart: Date?
    
    // Activity Report
    @State private var context: DeviceActivityReport.Context = .pieChart
    private var dateInterval: DateInterval {
        return DateInterval(start: selectedDateStart ?? Date.now, end: Date())
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
            
            Picker("", selection: $selectedDateStart) {
                Text("Today")
                    .tag(calendar.startOfDay(for: Date.now))
                Text("7 Days")
                    .tag(calendar.startOfDay(for: Calendar.current.date(byAdding: .day, value: -7, to: Date())!))
                Text("30 Days")
                    .tag(calendar.startOfDay(for: Calendar.current.date(byAdding: .day, value: -30, to: Date())!))
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .onAppear {
                selectedDateStart = calendar.startOfDay(for: Date.now)
            }
            
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
        .sensoryFeedback(.impact, trigger: selectedDateStart)
//        .padding()
    }
}

#Preview {
    ActivityReportView()
}
