//
//  StudyActivity.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 05.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import GameplayKit

enum ActivityType {
    case search, survey, reward
    
    var iconName: String {
        return "activity " + String(describing: self)
    }
    
    var title: String {
        switch self {
        case .search:
            return "Search task"
        case .survey:
            return "Survey"
        case .reward:
            return "Win a £20 Amazon voucher"
        }
    }
}

class StudyActivity {
    var startDate: Date
    var number: Int
    var type: ActivityType
    var stateMachine = ActivityStateMachine()
    
    init(startDate: Date, number: Int, type: ActivityType) {
        self.startDate = startDate
        self.number = number
        self.type = type
    }
    
    var isStartable: Bool {
        switch type {
        case .reward:
            return isStudyCompleted && isRewardSignupComplete == false
        case .survey:
            return isAllSearchTasksComplete && isSurveyComplete == false
        case .search:
            return timeRemaining <= 0 && stateMachine.currentState is DataAvailableState
        }
    }
    
    var isStudyCompleted: Bool {
        return UserDefaults.standard.object(forKey: SettingsString.preferredLayout.rawValue) != nil
    }
    
    var isRewardSignupComplete: Bool {
        return UserDefaults.standard.object(forKey: SettingsString.participantEmail.rawValue) != nil
    }
    
    var isAllSearchTasksComplete: Bool {
        let lastActivityNumber = UserDefaults.standard.integer(forKey: SettingsString.lastActivityNumber.rawValue)
        return lastActivityNumber == Const.StudyParameters.searchActivityCount - 1
    }
    
    var isSurveyComplete: Bool {
        return UserDefaults.standard.string(forKey: SettingsString.preferredLayout.rawValue) != nil
    }
    
    var daysRemaining: Int {
        return Int(timeRemaining) / (60*60*24)
    }
    
    var timeRemaining: TimeInterval {
        return startDate.timeIntervalSince(Date())
    }
    
    var timeRemainingString: String {
        switch type {
        case .search:
            let days = daysRemaining
            if days > 0 {
                return days == 1 ? "Available in \(days) day" : "Available in \(days) days"
            } else {
                return timeToString(time: timeRemaining)
            }
        case .survey:
            return "Available after last search task"
        case .reward:
            return "Available after survey"
        }
        
    }
    
    private func timeToString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "Available in %02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var description: String {
        return type.title
    }
    
    var identifier: String {
        return ("Activity \(number) " + description)
    }
}
