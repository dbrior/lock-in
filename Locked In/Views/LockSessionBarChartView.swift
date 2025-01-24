//
//  LockSessionBarChartView.swift
//  Locked In
//
//  Created by Daniel Brior on 1/23/25.
//

import SwiftUI
import SwiftData
import Charts

struct LockSessionBarChartView: View {
    @Environment(\.modelContext) private var context
    @Query private var sessions: [LockSession]
    let startDate: Date
    let endDate: Date
    
    private var dayRange: Int {
        return Int(endDate.timeIntervalSince(startDate) / (3600 * 24))
    }
    
    @State var isLocked = false // This not used, only here to satifsy child view
    @State var currentSessionDuration: TimeInterval = TimeInterval(0)
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var formatter = DateFormatter()
    var dateOnlyFormatter = DateFormatter()
    
    @State var rawChartSelection: Date?
    @State var chartSelectedDay: Date?
    
//    init() {
    init(startDate: Date, endDate: Date) {
        self._sessions = Query(filter: #Predicate<LockSession> {
            $0.startDate >= startDate && $0.startDate <= endDate
        }, sort: \.startDate, order: .reverse)
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dateOnlyFormatter.dateStyle = .medium
        dateOnlyFormatter.timeStyle = .none
        
        self.startDate = startDate
        self.endDate = endDate
    }
    
    var body: some View {
        VStack {
//            Text(formatter.string(from: startDate))
//            Text(formatter.string(from: endDate))
            // ------ Bar Chart ------
//            let calendar = Calendar.current
//            let today = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: .now)!)
//            let nDaysAgo = calendar.date(byAdding: .day, value: -(dayRange-1), to: today)!

            let groupedSessions = Dictionary(grouping: sessions.filter {
                $0.startDate >= startDate && $0.startDate <= endDate
            }) { session in
                Calendar.current.startOfDay(for: session.startDate)
            }

            let dailyTotalDurations = groupedSessions.map { (day, sessions) in
                (day: day, totalDuration: sessions.reduce(0) { $0 + $1.getDuration() })
            }

            Chart(dailyTotalDurations, id: \.day) { daySession in
                BarMark(
                    x: .value("Date", daySession.day, unit: .day),
                    y: .value("Total Locked Duration", daySession.totalDuration / 3600)
                )
                .annotation(position: .top, alignment: .center) {
                    if dayRange < 30 {
                        Text(verbatim: String(format: "%.1f", daySession.totalDuration / 3600) + " hrs")
                            .font(.caption)
                    } else {
                        Text("")
                    }
                }
                
                if chartSelectedDay != nil {
                    let dateKey: Date = Calendar.current.startOfDay(for: chartSelectedDay!)
                    let totalDuration: TimeInterval = dailyTotalDurations.first(where: { $0.day == dateKey })?.totalDuration ?? 0
                    RuleMark(x: .value("Index", chartSelectedDay! + TimeInterval(3600*12))) // + 12 hours
                        .annotation(
                            position: .topTrailing,
                            overflowResolution: .init(
                                    x: .fit(to: .chart),
                                    y: .fit(to: .chart)
                                  )
                        ) {
                            
                            VStack {
                                Text(verbatim: formatTimeInterval(timeInterval: totalDuration))
                                Text(verbatim: dateOnlyFormatter.string(from: chartSelectedDay!))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.black)
                                    .stroke(.blue, lineWidth: 1)
                            )
                        }
                }
            }
            .chartXSelection(value: $rawChartSelection)
            .onChange(of: rawChartSelection) {
                if rawChartSelection == nil {
                    chartSelectedDay = nil
                } else {
                    let calendar = Calendar.current
//                    withAnimation(.linear(duration: 0.05)) {
                        chartSelectedDay = calendar.startOfDay(for: rawChartSelection ?? Date.now)
//                    }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: .day)) { axisValue in
                    if dayRange >= 30 {
                        let index = axisValue.index
                        let validIdx = index == 1 || index == (dayRange-2) || index == (dayRange/3) || index == 2*(dayRange/3)
                        
                        if validIdx {
                            AxisGridLine()
                            AxisTick()
                            if index == 1 {
                                AxisValueLabel(format: .dateTime.day().month(), anchor: .topLeading)
                            } else if index == dayRange-2 {
                                AxisValueLabel(format: .dateTime.day().month(), anchor: .topTrailing)
                            } else {
                                AxisValueLabel(format: .dateTime.day().month(), anchor: .center)
                            }
                            
                        }
                    } else {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.day().month(), centered: true)
                    }
                }
            }
            .chartXScale(domain: startDate...endDate)
            .chartYAxis {
                AxisMarks() { value in
                    if value.index == 0 {
                        AxisGridLine()
                    }
                    AxisValueLabel {
                        Text("\(value.as(Double.self) ?? 0, specifier: "%.0f") hrs")
                    }
                }
            }
            .chartYScale(domain: [0, 24])
            .padding(.top)
            // ----------------------
            
            List(sessions, id:\.startDate) { session in
                VStack {
                    HStack {
                        let successfulSession: Bool = session.endDate == session.proposedEndDate
                        let symbolColor: Color = successfulSession ? .green : .red
                        Image(systemName: "\(successfulSession ? "checkmark" : "xmark").seal")
                            .font(.title)
                            .foregroundStyle(session.endDate == nil ? .clear : symbolColor)
                            .padding(.trailing)
                        
                        VStack {
                            HStack {
                                Text("\(formatter.string(from: session.startDate))")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            if (session.endDate != nil) {
                                HStack {
                                    Text("Duration: \(formatTimeInterval(timeInterval: session.duration))")
                                    Spacer()
                                }
                            } else {
                                HStack {
                                    Text("Duration: \(formatTimeInterval(timeInterval: currentSessionDuration))")
                                    Spacer()
                                }
                                .onReceive(timer) { time in
                                    currentSessionDuration = Date.now.timeIntervalSince(session.startDate)
                                    session.inProgressDuration = currentSessionDuration
                                }
                            }
                            
                            HorizontalScrollAppView(applications: session.lockedApplications, categories: session.lockedCategories, domains: session.lockedDomains, currentlyLocked: $isLocked)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

//#Preview {
//    LockSessionBarChartView()
//}
