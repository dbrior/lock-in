//
//  DebugControls.swift
//  Locked In
//
//  Created by Daniel Brior on 1/19/25.
//

import SwiftUI

struct DebugControlsView: View {
    @Environment(AppModel.self) var appModel: AppModel
    
    var body: some View {
        Button("Clear UserDefaults") {
            UserDefaults.standard.removePersistentDomain(forName: appModel.domain)
            UserDefaults.standard.synchronize()
        }
    }
}

#Preview {
    DebugControlsView()
}
