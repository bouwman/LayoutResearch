//
//  ActivityService.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 04.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

class ActivitiesService {
    private var dateFirstStarted: Date
    
    let activities: [StudyActivity]
    
    init() {
        dateFirstStarted = Date()
        activities = [StudyActivity(startDate: dateFirstStarted, number: 0, type: .searchIcons),
         StudyActivity(startDate: Calendar.current.date(byAdding: .day, value: 1, to: dateFirstStarted, wrappingComponents: false)!, number: 1, type: .searchIcons),
         StudyActivity(startDate: Calendar.current.date(byAdding: .day, value: 2, to: dateFirstStarted, wrappingComponents: false)!, number: 2, type: .searchIcons),
         StudyActivity(startDate: Calendar.current.date(byAdding: .day, value: 3, to: dateFirstStarted, wrappingComponents: false)!, number: 3, type: .searchIcons),
         StudyActivity(startDate: Calendar.current.date(byAdding: .day, value: 4, to: dateFirstStarted, wrappingComponents: false)!, number: 4, type: .searchIcons),
        StudyActivity(startDate: Calendar.current.date(byAdding: .day, value: 4, to: dateFirstStarted, wrappingComponents: false)!, number: 4, type: .survey)]
    }
    
    var activeActivity: StudyActivity?
    var attemptNumber: Int {
        set {
            UserDefaults.standard.setValue(attemptNumber, forKey: SettingsString.attemptNumber.rawValue)
        }
        get {
            return UserDefaults.standard.integer(forKey: SettingsString.attemptNumber.rawValue)
        }
    }
    
    var isParticipantGroupAssigned: Bool {
        set {
            UserDefaults.standard.setValue(isParticipantGroupAssigned, forKey: SettingsString.isParticipantGroupAssigned.rawValue)
        }
        get {
            return UserDefaults.standard.bool(forKey: SettingsString.isParticipantGroupAssigned.rawValue)
        }
    }
}
