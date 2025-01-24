//
//  SessionHistoryView.swift
//  Locked In
//
//  Created by Daniel Brior on 1/22/25.
//

import SwiftUI
import SwiftData
import Charts

struct SessionHistoryView: View {
    @State private var startDate: Date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -6, to: .now)!) // 7 Days ago
    var endDate: Date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!) - 1.0 // 23:59 for current day
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var formatter = DateFormatter()
    var dateOnlyFormatter = DateFormatter()
    
    var body: some View {
        VStack {
            HStack {
                Text("Sessions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            
//            HStack {
//                Text("Total Lock In Time:")
//                    .font(.headline)
//                Spacer()
//                Text("\(formatTimeInterval(timeInterval: allSessions.reduce(0) {$0 + $1.getDuration()}))")
//                Spacer()
//            }
            
            Picker("", selection: $startDate) {
                Text("Today")
                    .tag(Calendar.current.startOfDay(for: .now))
                Text("7 Days")
                    .tag(Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -6, to: .now)!))
                Text("30 Days")
                    .tag(Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -29, to: .now)!))
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            
            LockSessionBarChartView(startDate: startDate, endDate: endDate)
            
//            Button("Clear sessions") {
//                do {
//                    try context.delete(model: LockSession.self)
//                } catch {
//                    print("Failed to delete sessions.")
//                }
//            }
            
            
        }
    }
}

//#Preview {
//    SessionHistoryView()
//}
