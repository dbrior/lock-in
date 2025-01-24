//
//  Locked_InApp.swift
//  Locked In
//
//  Created by Daniel Brior on 1/12/25.
//

import SwiftUI
import SwiftData

func formatTimeInterval(timeInterval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.day, .hour, .minute, .second]
    formatter.unitsStyle = .abbreviated
    formatter.zeroFormattingBehavior = .dropAll
    
    return formatter.string(from: timeInterval) ?? "Unknown Time"
}

func getModelContainer() -> ModelContainer {
    let configuration = ModelConfiguration(groupContainer: ModelConfiguration.GroupContainer.identifier("group.Locked-In"))
    
    do {
        let container = try ModelContainer(
            for: LockSession.self,
            configurations: configuration
        )
        
        return container
    } catch {
        fatalError("Failed to create ModelContainer: \(error)")
    }
}

@main
struct Locked_In: App {
    // App data
    @State private var appModel: AppModel = AppModel.loadModelFromStorage() ?? AppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(getModelContainer())
                .environment(appModel)
        }
    }
}
