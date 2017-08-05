//
//  ActivityService.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 04.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

class ActivitiesService {
    var dateFirstStarted: Date {
        didSet {
            UserDefaults.standard.set(dateFirstStarted.timeIntervalSinceReferenceDate, forKey: SettingsString.firstActivityDate.rawValue)
            activities = ActivitiesService.createActivitiesBasedOnDateOfFirstActivity(date: dateFirstStarted, extraDay: 0)
        }
    }
    
    var activities: [StudyActivity]
    var resultService = ResultService()
    var remoteDataService = RemoteDataService()
    
    init() {
        let savedDateOptional = resultService.fileService.firstActivityCompletionDate
        var extraDay = 0
        if let savedDate = savedDateOptional {
            dateFirstStarted = savedDate
        } else {
            dateFirstStarted = Date()
            extraDay = 1
        }
        
        activities = ActivitiesService.createActivitiesBasedOnDateOfFirstActivity(date: dateFirstStarted, extraDay: extraDay)
    }
    
    var activeActivity: StudyActivity?
    
    var isParticipantGroupAssigned: Bool {
        set {
            UserDefaults.standard.setValue(isParticipantGroupAssigned, forKey: SettingsString.isParticipantGroupAssigned.rawValue)
        }
        get {
            return UserDefaults.standard.bool(forKey: SettingsString.isParticipantGroupAssigned.rawValue)
        }
    }
    
    static func createActivitiesBasedOnDateOfFirstActivity(date: Date, extraDay: Int) -> [StudyActivity] {
        return [StudyActivity(startDate: date, number: 0, type: .searchIcons),
                StudyActivity(startDate: Calendar.current.date(byAdding: .day, value: 1 + extraDay, to: date, wrappingComponents: false)!, number: 1, type: .searchIcons),
                StudyActivity(startDate: Calendar.current.date(byAdding: .day, value: 2 + extraDay, to: date, wrappingComponents: false)!, number: 2, type: .searchIcons),
                StudyActivity(startDate: Calendar.current.date(byAdding: .day, value: 3 + extraDay, to: date, wrappingComponents: false)!, number: 3, type: .searchIcons),
                StudyActivity(startDate: Calendar.current.date(byAdding: .day, value: 4 + extraDay, to: date, wrappingComponents: false)!, number: 4, type: .searchIcons),
                StudyActivity(startDate: Calendar.current.date(byAdding: .day, value: 4 + extraDay, to: date, wrappingComponents: false)!, number: 1, type: .survey)]
    }
}
