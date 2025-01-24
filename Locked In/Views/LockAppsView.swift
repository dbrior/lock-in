//
//  WalkthroughView.swift
//  Locked In
//
//  Created by Daniel Brior on 1/13/25.
//

import SwiftUI
import SwiftData
import FamilyControls
import ManagedSettings
import DeviceActivity
import AVFoundation

struct LockAppsView: View {
    // ------ Database ------
    @Environment(\.modelContext) private var context
    @Query(sort: \LockSession.startDate, order: .reverse) private var allSessions: [LockSession]
    var latestSession: LockSession? {
        allSessions.first
    }
    // ---------------------
    
    @Environment(AppModel.self) var appModel: AppModel
    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding: Bool = false
    
    @State var activitySelectorPresented: Bool = false
    
    @State var currentlyLocked: Bool = false
    @State var sessionStartTime: Date?
    @State var currentTime: Date = Date.now
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var sessionDuration: TimeInterval {
        if !currentlyLocked {
            return TimeInterval(0)
        } else {
            return currentTime.timeIntervalSince(sessionStartTime!)
        }
    }
    
    @State private var didInitialLoad: Bool = false
    
    var trackedItemCount: Int {
        return (
            appModel.trackedApplications.count +
            appModel.trackedCategories.count +
            appModel.trackedDomains.count
        )
    }
    
    func createDeviceActivityMonitor(name: String, startDate: Date, endDate: Date) {
        let deviceActivityCenter = DeviceActivityCenter()
        let activityName = DeviceActivityName(name)

        let components: Set<Calendar.Component> = [.hour, .minute, .second]
        
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents(components, from: startDate)
        let endComponents = calendar.dateComponents(components, from: endDate)

        let schedule = DeviceActivitySchedule(intervalStart: startComponents, intervalEnd: endComponents, repeats: false)

        let threshold = DateComponents(minute: 1)
        let event = DeviceActivityEvent(threshold: threshold)
        let eventName = DeviceActivityEvent.Name(name+"Event")

        do {
            try deviceActivityCenter.startMonitoring(activityName, during: schedule, events: [eventName: event])
            print("\(name) event created")
        } catch {
            print("Error creating \(name) event")
        }
    }
    
    func toggleLock() {
        // ------ Code before toggle happens ------
        if !currentlyLocked {   // About to become locked
            print("Selected minutes", selectedMinutes)
            sessionStartTime = Date.now
            desiredSessionDuration = TimeInterval((selectedHours*3600) + (selectedMinutes*60))
            
            let proposedEndDate = sessionStartTime!.addingTimeInterval(desiredSessionDuration!)
            
            // Create db entry
            let sessionEntry = LockSession(
                startDate: sessionStartTime!,
                proposedEndDate: proposedEndDate,
                lockedApplications: appModel.trackedApplications,
                lockedCategories: appModel.trackedCategories,
                lockedDomains: appModel.trackedDomains
            )
            context.insert(sessionEntry)
            
            remainingHours = Int(remainingSessionDuration) / 3600
            remainingMinutes = (Int(remainingSessionDuration) % 3600) / 60
            remainingSeconds = Int(remainingSessionDuration) % 60
        } else {                // About to become unlocked
            // Set end date of session in db
            if Date.now < latestSession!.proposedEndDate {
                latestSession!.endDate = Date.now
            } else {
                latestSession!.endDate = latestSession!.proposedEndDate
            }
        }
        // ----------------------------------------
        
        currentlyLocked.toggle()
        
        // ------ Code after toggle happens ------
        // Just became locked
        if currentlyLocked {
            // ACTUAL LOCKING DONE IN ACTIVITY MONITOR
            createDeviceActivityMonitor(name: "LockedInAppBlock", startDate: sessionStartTime!, endDate: sessionStartTime!.addingTimeInterval(desiredSessionDuration!))
        } else {
            let deviceActivityCenter = DeviceActivityCenter()
            deviceActivityCenter.stopMonitoring()
            
            appModel.store.shield.applications = nil
            appModel.store.shield.webDomains = nil
            
            withAnimation(.linear(duration: 0.5)) {
                timerFill = 1.0
            }
        }
        // ---------------------------------------
    }
    
    @State var selectedHours: Int = 1
    @State var selectedMinutes: Int = 0
    
    @State var remainingHours: Int = 0
    @State var remainingMinutes: Int = 0
    @State var remainingSeconds: Int = 0
    
    @State var desiredSessionDuration: TimeInterval?
    
    var remainingSessionDuration: TimeInterval {
        if desiredSessionDuration == nil {
            return TimeInterval(0)
        }
        
        return desiredSessionDuration! - sessionDuration
    }
    
    @State var timerFill: Double = 1.0
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Lock In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .onAppear {
                if !didInitialLoad {
                    if latestSession != nil {
                        // Cases that happen while app is open should already be covered
                        
                        // Case 1: Session ended after app was closed
                        // - Its okay to stay in the unlcoked state
                        // - Need to set the end date for the session
                        if latestSession!.endDate == nil && latestSession!.proposedEndDate <= Date.now {
                            latestSession!.endDate = latestSession!.proposedEndDate
                        }
                        // Case 2: Session is still active even after app was closed
                        // - Need to set remaining time
                        // - Need to set to locked viz
                        // - Might need to set locked apps? Maybe not
                        else if latestSession!.endDate == nil && latestSession!.proposedEndDate > Date.now {
                            sessionStartTime = latestSession!.startDate
                            desiredSessionDuration = latestSession!.proposedEndDate.timeIntervalSince(sessionStartTime!)
                            currentlyLocked = true
                        }
                        
                    }
                    didInitialLoad = true
                }
            }
            
            TrackedAppsCardView(isPresented: $activitySelectorPresented, currentlyLocked: $currentlyLocked)
                .padding(.horizontal)
                .padding(.top)
            
            Divider()
            
            VStack {
                if currentlyLocked {
                    EmptyView()
                        .onReceive(timer) { time in
                            currentTime = time
                            
//                            withAnimation(.easeInOut(duration: 0.05)) {
                            remainingHours = Int(remainingSessionDuration) / 3600
                            remainingMinutes = (Int(remainingSessionDuration) % 3600) / 60
                            remainingSeconds = Int(remainingSessionDuration) % 60
//                            }
                            
                            withAnimation(.linear(duration: 1)) {
                                timerFill = 1.0 - (sessionDuration / desiredSessionDuration!)
                            }
                        }
                        .onChange(of: sessionDuration) {
                            if sessionDuration >= desiredSessionDuration! {
                                print(sessionDuration)
                                print(desiredSessionDuration!)
                                toggleLock()
                            }
                        }
                }
                
                HStack {
                    Text("Lock Duration:")
                    .font(.headline)
                    
                    Spacer()
                }
                
                HStack {
                    // Hours
                    HStack {
                        if currentlyLocked {
                            Text(String(remainingHours))
                        } else {
                            Picker("Hours", selection: $selectedHours) {
                                ForEach(0...23, id: \.self) { hour in
                                    Text("\(hour)").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
//                            .disabled(currentlyLocked)
                        }
                        
                        Text("hr")
                    }
                    
                    // Minutes
                    HStack {
                        if currentlyLocked {
                            Text(String(remainingMinutes))
                        } else {
                            Picker("Minute(s)", selection: $selectedMinutes) {
                                ForEach([0,15,30,45], id: \.self) { minute in
                                    Text("\(minute)").tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
//                            .disabled(currentlyLocked)
                        }
                        
                        Text("min")
                    }
                    
                    // Seconds
                    if currentlyLocked {
                        Text(String(remainingSeconds))
                        Text("sec")
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .padding(.horizontal)
            .padding(.top)
            
            Spacer()
            
            if trackedItemCount == 0 {
                Button(action: {activitySelectorPresented = true}, label: {
                    ZStack {
                        Text("SELECT APPS")
                            .font(.headline)
                            .fontWeight(.bold)
                            .scaledToFill()
                            .foregroundStyle(.blue)
                        Circle()
                            .fill(.clear)
                            .stroke(.blue, lineWidth: 10)
                    }
                })
                .sensoryFeedback(.impact, trigger: currentlyLocked)
                .buttonStyle(.plain)
                .shadow(radius: 10)
                .padding()
                .padding()
                .padding()
            } else {
                Button(action: toggleLock, label: {
                    ZStack {
                        ZStack {
                            Image(systemName: "lock")
                                .resizable()
                                .foregroundStyle(.blue)
                                .scaledToFit()
                                .containerRelativeFrame(.vertical, count: 10, span: 1, spacing: 0)
                                .opacity(currentlyLocked ? 1 : 0)
                            
                            Image(systemName: "lock.open")
                                .resizable()
                                .foregroundStyle(selectedHours == 0 && selectedMinutes == 0 ? .gray : .blue)
                                .scaledToFit()
                                .containerRelativeFrame(.vertical, count: 10, span: 1, spacing: 0)
                                .opacity(currentlyLocked ? 0 : 1)
                        }
                        .animation(.spring(), value: currentlyLocked)

                        Circle()
                            .trim(from: 0, to: timerFill)
                            .fill(.clear)
                            .stroke(
                                selectedHours == 0 && selectedMinutes == 0 ? .gray : .blue,
                                lineWidth: 10
                            )
                            .rotationEffect(.degrees(-90))
                            .scaleEffect(x: -1)
                    }
                })
                .disabled(selectedHours == 0 && selectedMinutes == 0)
                .sensoryFeedback(.impact, trigger: currentlyLocked)
                .buttonStyle(.plain)
                .shadow(radius: 10)
                .padding()
                .padding()
                .padding()
            }

            
            Spacer()
        }
    }
}

#Preview {
    var previewModel: AppModel = AppModel()
    
    LockAppsView()
        .padding()
        .environment(previewModel)
}
