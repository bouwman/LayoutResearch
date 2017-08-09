//
//  ActivityService.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 04.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

class ActivitiesService {
    var activities: [StudyActivity]
    let resultService = ResultService()
    let remoteDataService = RemoteDataService()
    let surveyService = SurveyService()
    let rewardService = RewardService()
    var activeActivity: StudyActivity?
    
    init() {
        let timeInterval = UserDefaults.standard.double(forKey: SettingsString.lastActivityCompletionDate.rawValue)
        var date = timeInterval == 0 ? Date() : Date(timeIntervalSinceReferenceDate: timeInterval)
        let number = UserDefaults.standard.object(forKey: SettingsString.lastActivityNumber.rawValue) as? Int

        // Make sure later activities don't become available, if last activity is older than 24 h
        let oneDayBack = Calendar.current.date(byAdding: .day, value: -1, to: Date(), wrappingComponents: false)!
        if date < oneDayBack {
            date = oneDayBack
        }
        
        activities = ActivitiesService.createActivitiesBasedOnLastActivityDate(lastDate: date, activityNumber: number)
    }
    
    var lastActivityDate: Date {
        get {
            let timeInterval = UserDefaults.standard.double(forKey: SettingsString.lastActivityCompletionDate.rawValue)
            return timeInterval == 0 ? Date() : Date(timeIntervalSinceReferenceDate: timeInterval)
        }
    }
    
    func setLastActivityDate(_ date: Date, forActivityNumber number: Int?) {
        UserDefaults.standard.set(date.timeIntervalSinceReferenceDate, forKey: SettingsString.lastActivityCompletionDate.rawValue)
        activities = ActivitiesService.createActivitiesBasedOnLastActivityDate(lastDate: date, activityNumber: number)
    }
    
    var lastActivityNumber: Int? {
        get {
            return UserDefaults.standard.object(forKey: SettingsString.lastActivityNumber.rawValue) as? Int
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingsString.lastActivityNumber.rawValue)
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
    
    static func createActivitiesBasedOnLastActivityDate(lastDate: Date, activityNumber: Int?) -> [StudyActivity] {
        let extraDay = activityNumber == nil ? 1 : 0
        let number = activityNumber ?? 0
        var activities: [StudyActivity] = []
        
        for i in 0..<Const.StudyParameters.searchActivityCount {
            let activity: StudyActivity
            if i <= number {
                activity = StudyActivity(startDate: lastDate, number: i, type: .search)
            } else {
                activity = StudyActivity(startDate: Calendar.current.date(byAdding: .day, value: i - number + extraDay, to: lastDate, wrappingComponents: false)!, number: i, type: .search)
            }
            activities.append(activity)
        }
        
        // Survey
        let survey = StudyActivity(startDate: activities.last!.startDate, number: activities.count, type: .survey)
        activities.append(survey)
        
        // Reward
        let reward = StudyActivity(startDate: survey.startDate, number: activities.count, type: .reward)
        activities.append(reward)
        
        return activities
    }
}
