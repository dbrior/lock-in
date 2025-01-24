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
    // --- Date Filtering ---
    private let startDate: Date
    private let endDate: Date
    
    private var dayCount: Int {
        if sessionTotalsByDay == nil {
            return 0
        } else {
            return sessionTotalsByDay!.keys.count
        }
    }
    // ----------------------
    
    // ------ Database ------
    @Environment(\.modelContext) private var context
    @State private var sessions: [LockSession]?
    @State private var sessionTotalsByDay: [Date:TimeInterval]?
    
    private var resultPageSize: Int = 30
    @State private var resultPageIdx: Int = 0
    
    private func queryDayTotals(queryStartDate: Date, queryEndDate: Date) async -> [Date:TimeInterval]? {
        let descriptor = FetchDescriptor<LockSession>(
            predicate: #Predicate<LockSession> {
                $0.startDate >= queryStartDate && $0.startDate <= queryEndDate
            },
            sortBy: [.init(\.startDate, order: .reverse)]
        )
        
        let pulledSessions: [LockSession]
        do {
            pulledSessions = try context.fetch(descriptor)
        } catch {
            return [:]
        }
        
        return Dictionary(grouping: pulledSessions) { session in
            Calendar.current.startOfDay(for: session.startDate)
        }.mapValues { sessionsForDay in
            sessionsForDay.reduce(0) { $0 + $1.duration }
        }
    }
    
    private func querySessions(queryStartDate: Date, queryEndDate: Date) async -> [LockSession] {
        var descriptor = FetchDescriptor<LockSession>(
            predicate: #Predicate<LockSession> {
                $0.startDate >= queryStartDate && $0.startDate <= queryEndDate
            },
            sortBy: [.init(\.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = resultPageSize
        descriptor.fetchOffset = resultPageSize * resultPageIdx
        
        do {
            return try context.fetch(descriptor)
        } catch {
            return []
        }
    }
    // ----------------------
    
    // --- Chart Selection ---
    @State var rawChartSelection: Date?
    var chartSelectedDay: Date? {
        if rawChartSelection == nil {
            return nil
        } else {
            return Calendar.current.startOfDay(for: rawChartSelection!)
        }
    }
    // -----------------------
    
    @State var isLocked = false // This not used, only here to satifsy child view
    @State var currentSessionDuration: TimeInterval = TimeInterval(0)
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var formatter = DateFormatter()
    var dateOnlyFormatter = DateFormatter()
    
//    init() {
    init(startDate: Date, endDate: Date) {
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dateOnlyFormatter.dateStyle = .medium
        dateOnlyFormatter.timeStyle = .none
        
        self.startDate = startDate
        self.endDate = endDate
    }
    
    var body: some View {
        VStack {
            if sessionTotalsByDay == nil {
                Spacer()
                ProgressView()
                Spacer()
            } else if sessionTotalsByDay == [:] {
                Spacer()
                Text("No data")
                Spacer()
                Divider()
            } else {
                Chart(Array(sessionTotalsByDay!.keys), id:\.self) { dateKey in
                    let dayTotalDuration = sessionTotalsByDay![dateKey] ?? TimeInterval(0)
                    
                    BarMark(
                        x: .value("Date", dateKey, unit: .day),
                        y: .value("Total Locked Duration", dayTotalDuration / 3600)
                    )
                    .annotation(position: .top, alignment: .center) {
                        if dayCount < 29 {
                            Text(verbatim: String(format: "%.1f", dayTotalDuration / 3600) + " hr")
                                .font(.caption)
                        } else {
                            Text("")
                        }
                    }
                    
                    if chartSelectedDay != nil {
                        let selectionDateKey: Date = Calendar.current.startOfDay(for: chartSelectedDay!)
                        let selectionTotalDuration: TimeInterval = sessionTotalsByDay![selectionDateKey] ?? TimeInterval(0)
                        RuleMark(x: .value("Index", chartSelectedDay! + TimeInterval(3600*12))) // + 12 hours
                            .annotation(
                                position: .topTrailing,
                                overflowResolution: .init(
                                    x: .fit(to: .chart),
                                    y: .fit(to: .chart)
                                )
                            ) {
                                
                                VStack {
                                    Text(verbatim: formatTimeInterval(timeInterval: selectionTotalDuration))
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
                .chartXAxis {
                    AxisMarks(preset: .aligned, values: .stride(by: .day)) { axisValue in
                        
                        if dayCount == 0 {
                            
                        } else if dayCount >= 30 {
                            let index = axisValue.index
                            let validIdx = index == 0 || index == (dayCount-1) || index == (dayCount/3) || index == 2*(dayCount/3)
                            
                            if validIdx {
                                AxisGridLine()
                                AxisTick()
                                if index == 0 {
                                    AxisValueLabel(format: .dateTime.day().month(), anchor: .topLeading)
                                } else if index == dayCount-1 {
                                    AxisValueLabel(format: .dateTime.day().month(), anchor: .top)
                                } else {
                                    AxisValueLabel(format: .dateTime.day().month(), anchor: .top)
                                }
                                
                            }
                        } else {
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.day().month(), anchor: .topLeading)
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
                            Text("\(value.as(Double.self) ?? 0, specifier: "%.0f") hr")
                        }
                    }
                }
                .chartYScale(domain: [0, 24])
                .padding(.top)
                // ----------------------
            }
            
            if sessions == nil {
                Spacer()
                ProgressView()
                Spacer()
            } else if sessions == [] {
                Spacer()
                Text("No data")
                Spacer()
            } else {
                List(sessions!, id:\.startDate) { session in
                    VStack {
                        HStack {
                            // Date and duration
                            VStack {
                                HStack {
                                    Text("\(formatter.string(from: session.startDate))")
                                        .font(.headline)
                                    Spacer()
                                }
                                
                                if (session.endDate != nil) {
                                    HStack {
                                        Text("Lock duration: \(formatTimeInterval(timeInterval: session.duration))")
                                        Spacer()
                                    }
                                } else {
                                    HStack {
                                        Text("Lock duration: \(formatTimeInterval(timeInterval: currentSessionDuration))")
                                        Spacer()
                                    }
                                    .onReceive(timer) { time in
                                        currentSessionDuration = Date.now.timeIntervalSince(session.startDate)
                                        session.inProgressDuration = currentSessionDuration
                                    }
                                }
                            }
                            
                            // Status Icon
                            let successfulSession: Bool = session.endDate == session.proposedEndDate
                            let symbolColor: Color = successfulSession ? .green : .red
                            Image(systemName: "\(successfulSession ? "checkmark" : "xmark").seal")
                                .font(.title)
                                .foregroundStyle(session.endDate == nil ? .clear : symbolColor)
                                .padding(.trailing)
                        }
                        
                        // App icons
                        HorizontalScrollAppView(applications: session.lockedApplications, categories: session.lockedCategories, domains: session.lockedDomains, currentlyLocked: $isLocked)
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            Task { @MainActor in
                do {
                    sessionTotalsByDay = await queryDayTotals(queryStartDate: startDate, queryEndDate: endDate)
                    sessions = await querySessions(queryStartDate: startDate, queryEndDate: endDate)
                }
            }
        }
        .onChange(of: startDate) {
            Task { @MainActor in
                do {
                    sessionTotalsByDay = await queryDayTotals(queryStartDate: startDate, queryEndDate: endDate)
                    sessions = await querySessions(queryStartDate: startDate, queryEndDate: endDate)
                }
            }
        }
    }
}

//#Preview {
//    LockSessionBarChartView()
//}
