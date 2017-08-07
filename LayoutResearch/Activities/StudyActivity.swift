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
            return "Reward"
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
        if type == .reward {
            return isStudyCompleted
        } else {
            return timeRemaining <= 0 && stateMachine.currentState is DataAvailableState
        }
    }
    
    var isStudyCompleted: Bool {
        return UserDefaults.standard.object(forKey: SettingsString.preferredLayout.rawValue) != nil
    }
    
    var daysRemaining: Int {
        return Int(timeRemaining) / (60*60*24)
    }
    
    var timeRemaining: TimeInterval {
        return startDate.timeIntervalSince(Date())
    }
    
    var timeRemainingString: String {
        let days = daysRemaining
        if days > 0 {
            return days == 1 ? "Available in \(days) day" : "Available in \(days) days"
        } else {
            return timeToString(time: timeRemaining)
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
