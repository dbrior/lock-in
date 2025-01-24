//
//  LockSession.swift
//  Locked In
//
//  Created by Daniel Brior on 1/22/25.
//

import Foundation
import SwiftData
import ManagedSettings

@Model
class LockSession {
    var startDate: Date
    var proposedEndDate: Date
    var endDate: Date?
    var inProgressDuration: TimeInterval = TimeInterval(0)
    var duration: TimeInterval {
        if endDate == nil {
            return TimeInterval(0)
        } else {
            return endDate!.timeIntervalSince(startDate)
        }
    }
    
    var lockedApplications: Set<ApplicationToken>
    var lockedCategories: Set<ActivityCategoryToken>
    var lockedDomains: Set<WebDomainToken>
    
    init(
        startDate: Date,
        proposedEndDate: Date,
        endDate: Date? = nil,
        
        lockedApplications: Set<ApplicationToken>,
        lockedCategories: Set<ActivityCategoryToken>,
        lockedDomains: Set<WebDomainToken>
    ) {
        self.startDate = startDate
        self.proposedEndDate = proposedEndDate
        self.endDate = endDate
        
        self.lockedApplications = lockedApplications
        self.lockedCategories = lockedCategories
        self.lockedDomains = lockedDomains
    }
    
    func getDuration() -> TimeInterval {
        if endDate == nil {
            return inProgressDuration
        } else {
            return duration
        }
    }
}
