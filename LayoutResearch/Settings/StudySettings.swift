//
//  StudySettings.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 30.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

enum ParticipantGroup: String, CustomStringConvertible, SelectionPresentable {
    case a,b,c,d,e,f,g,h,i,j,k,l
    
    var layouts: [LayoutType] {
        switch self {
        case .a,.g:
            return [.grid, .horizontal, .vertical]
        case .b,.h:
            return [.grid, .vertical, .horizontal]
        case .c,.i:
            return [.horizontal, .grid, .vertical]
        case .d,.j:
            return [.vertical, .grid, .horizontal]
        case .e,.k:
            return [.vertical, .horizontal, .grid]
        case .f,.l:
            return [.horizontal, .vertical, .grid]
        }
    }
    
    var organisation: OrganisationType {
        switch self {
        case .a,.b,.c,.d,.e,.f:
            return .stable
        case .g,.h,.i,.j,.k,.l:
            return .random
        }
    }
    
    var description: String {
        return "Group \(self.rawValue.uppercased())"
    }
    
    var title: String {
        return description
    }
    
    func next() -> ParticipantGroup {
        let currentIndex = ParticipantGroup.allGroups.index(of: self)!
        if currentIndex == ParticipantGroup.allGroups.count - 1 {
            return ParticipantGroup.allGroups.first!
        } else {
            return ParticipantGroup.allGroups[currentIndex + 1]
        }
    }
    
    private static var allGroups: [ParticipantGroup] {
        return [.a,.b,.c,.d,.e,.f,.g,.h,.i,.j,.k,.l]
    }
    
    static var random: ParticipantGroup {
        return ParticipantGroup.allGroups[randomInt(min: 0, max: allGroups.count - 1)]
    }
}

enum TargetGroup: String {
    case a, b
    
    func next() -> TargetGroup {
        return self == .a ? .b : .a
    }
    
    func targetItemsFrom(searchItems: [[SearchItemProtocol]]) -> [SearchItemProtocol] {
        let a,b,c,d,e,f,g,h,i,j : SearchItemProtocol
        switch self {
        case .a:
            // Color distractor count high
            a = searchItems[2][1] // Blue
            b = searchItems[1][3] // Blue
            c = searchItems[1][1] // Orange
            d = searchItems[4][3] // Orange
            
            // Color distractor count low
            e = searchItems[2][2] // Dark green
            f = searchItems[3][2] // Dark green
            g = searchItems[1][2] // Dark blue
            h = searchItems[4][1] // Dark blue
            i = searchItems[0][2] // Green
            j = searchItems[5][1] // Green
        case .b:
            // Color distractor count high
            a = searchItems[4][2] // Pink
            b = searchItems[5][2] // Pink
            c = searchItems[3][1] // Orange
            d = searchItems[2][0] // Orange
            
            // Color distractor count low
            e = searchItems[3][2] // Dark green
            f = searchItems[2][2] // Dark green
            g = searchItems[4][1] // Dark blue
            h = searchItems[1][2] // Dark blue
            i = searchItems[5][1] // Green
            j = searchItems[0][2] // Green
        }
        
        let items: [SearchItemProtocol] = [a, j, g, h, c, f, e, i, a, g, c, e, b, i, d, a, j, g, h, c, f, e, i, a, g, c, e, b, i, d]
        
        return items
    }
}

struct StudySettings {
    var participant: String
    var group: ParticipantGroup
    var targetGroup: TargetGroup
    var rowCount: Int
    var columnCount: Int
    var itemDiameter: CGFloat
    var itemDistance: CGFloat
    var practiceTrialCount: Int
    var targetFreqLowCount: Int
    var targetFreqHighCount: Int
    var distractorColorLowCount: Int
    var distractorColorHighCount: Int
    
    func itemDistanceWithEqualWhiteSpaceFor(layout: LayoutType) -> CGFloat {
        switch layout {
        case .grid:
            return itemDistance
        case .horizontal, .vertical:
            let multiplier: CGFloat = abs((sqrt(3)-sqrt(2)*pow(3, 0.25))/sqrt(3))
            return itemDistance + multiplier * itemDiameter + multiplier * itemDistance
        }
    }
    
    func saveToUserDefaults(userDefaults: UserDefaults) {
        userDefaults.set(participant, forKey: SettingsString.participantIdentifier.rawValue)
        userDefaults.set(group.rawValue, forKey: SettingsString.participantGroup.rawValue)
        userDefaults.set(targetGroup.rawValue, forKey: SettingsString.targetGroup.rawValue)
        userDefaults.set(itemDiameter, forKey: SettingsString.layoutItemDiameter.rawValue)
        userDefaults.set(itemDistance, forKey: SettingsString.layoutItemDistance.rawValue)
        userDefaults.set(rowCount, forKey: SettingsString.layoutRowCount.rawValue)
        userDefaults.set(columnCount, forKey: SettingsString.layoutColumnCount.rawValue)
        userDefaults.set(practiceTrialCount, forKey: SettingsString.practiceTrialCount.rawValue)
        userDefaults.set(targetFreqLowCount, forKey: SettingsString.targetFreqLowCount.rawValue)
        userDefaults.set(targetFreqHighCount, forKey: SettingsString.targetFreqHighCount.rawValue)
        userDefaults.set(distractorColorLowCount, forKey: SettingsString.distractorColorLowCount.rawValue)
        userDefaults.set(distractorColorHighCount, forKey: SettingsString.distractorColorHighCount.rawValue)
        
        UserDefaults.standard.synchronize()
    }
    
    static func fromUserDefaults(userDefaults: UserDefaults) -> StudySettings? {
        let userIdOptional = userDefaults.string(forKey: SettingsString.icloudUserId.rawValue)
        let groupStringOptional = userDefaults.string(forKey: SettingsString.participantGroup.rawValue)
        let targetGroupStringOptional = userDefaults.string(forKey: SettingsString.targetGroup.rawValue)
        let rowCount = userDefaults.integer(forKey: SettingsString.layoutRowCount.rawValue)
        let columnCount = userDefaults.integer(forKey: SettingsString.layoutColumnCount.rawValue)
        let itemDiameter = userDefaults.float(forKey: SettingsString.layoutItemDiameter.rawValue)
        let itemDistance = userDefaults.float(forKey: SettingsString.layoutItemDistance.rawValue)
        let practiceTrialCount = userDefaults.integer(forKey: SettingsString.practiceTrialCount.rawValue)
        let targetFreqLowCount = userDefaults.integer(forKey: SettingsString.targetFreqLowCount.rawValue)
        let targetFreqHighCount = userDefaults.integer(forKey: SettingsString.targetFreqHighCount.rawValue)
        let distractorColorLowCount = userDefaults.integer(forKey: SettingsString.distractorColorLowCount.rawValue)
        let distractorColorHighCount = userDefaults.integer(forKey: SettingsString.distractorColorHighCount.rawValue)
        
        let participantIdentifierOptional: String?
        if let userId = userIdOptional {
            participantIdentifierOptional = userId
        } else {
            participantIdentifierOptional = userDefaults.string(forKey: SettingsString.participantIdentifier.rawValue)
        }
        
        guard let groupString = groupStringOptional else { return nil }
        guard let targetGroupString = targetGroupStringOptional else { return nil }
        guard let targetGroup = TargetGroup(rawValue: targetGroupString) else { return nil }
        guard let group = ParticipantGroup(rawValue: groupString) else { return nil }
        guard let participant = participantIdentifierOptional else { return nil }
        
        return StudySettings(participant: participant, group: group, targetGroup: targetGroup, rowCount: rowCount, columnCount: columnCount, itemDiameter: CGFloat(itemDiameter), itemDistance: CGFloat(itemDistance), practiceTrialCount: practiceTrialCount, targetFreqLowCount: targetFreqLowCount, targetFreqHighCount: targetFreqHighCount, distractorColorLowCount: distractorColorLowCount, distractorColorHighCount: distractorColorHighCount)
    }
    
    static func defaultSettingsForParticipant(_ participant: String) -> StudySettings {
        return StudySettings(participant: participant, group: ParticipantGroup.random, targetGroup: .a, rowCount: Const.StudyParameters.rowCount, columnCount: Const.StudyParameters.columnCount, itemDiameter: Const.StudyParameters.itemDiameter, itemDistance: Const.StudyParameters.itemDistance, practiceTrialCount: Const.StudyParameters.practiceTrialCount, targetFreqLowCount: Const.StudyParameters.targetFreqLowCount, targetFreqHighCount: Const.StudyParameters.targetFreqHighCount, distractorColorLowCount: Const.StudyParameters.distractorColorLowCount, distractorColorHighCount: Const.StudyParameters.distractorColorHighCount)
    }
}
