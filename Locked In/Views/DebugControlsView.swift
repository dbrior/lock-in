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
        VStack {
            HStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Spacer()
            
            Button("Clear UserDefaults") {
                UserDefaults.standard.removePersistentDomain(forName: appModel.domain)
                UserDefaults.standard.synchronize()
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
    }
}

#Preview {
    var previewModel: AppModel = AppModel()
    
    DebugControlsView()
        .padding()
        .environment(previewModel)
}
