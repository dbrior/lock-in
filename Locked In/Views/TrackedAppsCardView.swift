//
//  TrackedAppsCardView.swift
//  Locked In
//
//  Created by Daniel Brior on 1/21/25.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct HorizontalScrollAppView : View {
    var applications: Set<ApplicationToken>
    var categories: Set<ActivityCategoryToken>
    var domains: Set<WebDomainToken>
    
    @Binding var currentlyLocked: Bool
    
    var allItemCount: Int {
        return applications.count + categories.count + domains.count
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 25) {
                if allItemCount == 0 {
                    Color.clear
                        .frame(width: UIScreen.main.bounds.size.width*0.15, height: 50)
                    Text("No selected apps")
                    Color.clear
                        .frame(width: UIScreen.main.bounds.size.width*0.15, height: 50)
                } else {
                    if allItemCount < 6 {
                        Color.clear
                            .frame(width: CGFloat(5-allItemCount)*25.0, height: 50)
                    }
                    
                    ForEach(Array(categories), id: \.self) { item in
                        if currentlyLocked {
                            Label(item)
                                .labelStyle(.iconOnly)
                                .scaleEffect(2)
                                .opacity(0.75)
                                .overlay(alignment: .topTrailing) {
                                    ZStack {
                                        Circle()
                                            .fill(.black)
                                            .frame(width: 20, height: 20)
                                        Image(systemName: "lock")
                                            .font(.system(size: 10))
                                            .foregroundStyle(.blue)
                                    }
                                    .offset(x:10, y:-10)
                                }
                        } else {
                            ZStack {
                                Label(item)
                                    .labelStyle(.iconOnly)
                                    .scaleEffect(2)
                            }
                        }
                    }
                    
                    ForEach(Array(applications), id: \.self) { item in
                        if currentlyLocked {
                            Label(item)
                                .labelStyle(.iconOnly)
                                .scaleEffect(2)
                                .opacity(0.75)
                                .overlay(alignment: .topTrailing) {
                                    ZStack {
                                        Circle()
                                            .fill(.black)
                                            .frame(width: 20, height: 20)
                                        Image(systemName: "lock")
                                            .font(.system(size: 10))
                                            .foregroundStyle(.blue)
                                    }
                                    .offset(x:10, y:-10)
                                }
                        } else {
                            ZStack {
                                Label(item)
                                    .labelStyle(.iconOnly)
                                    .scaleEffect(2)
                            }
                        }
                    }
                    ForEach(Array(domains), id: \.self) { item in
                        if currentlyLocked {
                            Label(item)
                                .labelStyle(.iconOnly)
                                .scaleEffect(2)
                                .opacity(0.75)
                                .overlay(alignment: .topTrailing) {
                                    ZStack {
                                        Circle()
                                            .fill(.black)
                                            .frame(width: 20, height: 20)
                                        Image(systemName: "lock")
                                            .font(.system(size: 10))
                                            .foregroundStyle(.blue)
                                    }
                                    .offset(x:10, y:-10)
                                }
                        } else {
                            ZStack {
                                Label(item)
                                    .labelStyle(.iconOnly)
                                    .scaleEffect(2)
                            }
                        }
                    }
                    
                    if allItemCount < 6 {
                        Color.clear
                            .frame(width: CGFloat(5-allItemCount)*25.0, height: 50)
                    }
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 5)
        }
        .defaultScrollAnchor(.center)
    }
}

struct TrackedAppsCardView : View {
    @Environment(AppModel.self) var appModel: AppModel
    @State var selection = FamilyActivitySelection()
    @Binding var isPresented: Bool
    
    @Binding var currentlyLocked: Bool
    
    var allSelectionCount: Int {
        return appModel.trackedCategories.count + appModel.trackedApplications.count + appModel.trackedDomains.count
    }
    
    var body : some View {
        VStack {
            HStack {
                Text("Tracked apps:")
                    .font(.headline)
                Spacer()
                Button {
                    isPresented = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .familyActivityPicker(isPresented: $isPresented, selection: $selection)
                .onChange(of: selection) {
                    appModel.saveFamilyPickerSelections(
                        newCategories: selection.categoryTokens,
                        newApplications: selection.applicationTokens,
                        newDomains: selection.webDomainTokens
                    )
                    
                    selection.categoryTokens = appModel.trackedCategories
                    selection.applicationTokens = appModel.trackedApplications
                    selection.webDomainTokens = appModel.trackedDomains
                }
                .onAppear {
                    selection.categoryTokens = appModel.trackedCategories
                    selection.applicationTokens = appModel.trackedApplications
                    selection.webDomainTokens = appModel.trackedDomains
                }
                .disabled(currentlyLocked)
                .opacity(currentlyLocked ? 0.5 : 1)
            }
            
            HorizontalScrollAppView(applications: appModel.trackedApplications, categories: appModel.trackedCategories, domains: appModel.trackedDomains, currentlyLocked: $currentlyLocked)
        }
    }
}

#Preview {
    var previewModel: AppModel = AppModel()
    @State var previewCurrentlyLocked = true
    @State var previewCurrentlyPresented = false
    
    TrackedAppsCardView(isPresented: $previewCurrentlyPresented, currentlyLocked: $previewCurrentlyLocked)
        .environment(previewModel)
}
