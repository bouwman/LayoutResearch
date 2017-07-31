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
}

struct StudySettings {
    var participant: String
    var group: ParticipantGroup
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
        let participantOptional = userDefaults.string(forKey: SettingsString.participantIdentifier.rawValue)
        let groupStringOptional = userDefaults.string(forKey: SettingsString.participantGroup.rawValue)
        let rowCount = userDefaults.integer(forKey: SettingsString.layoutRowCount.rawValue)
        let columnCount = userDefaults.integer(forKey: SettingsString.layoutColumnCount.rawValue)
        let itemDiameter = userDefaults.float(forKey: SettingsString.layoutItemDiameter.rawValue)
        let itemDistance = userDefaults.float(forKey: SettingsString.layoutItemDistance.rawValue)
        let practiceTrialCount = userDefaults.integer(forKey: SettingsString.practiceTrialCount.rawValue)
        let targetFreqLowCount = userDefaults.integer(forKey: SettingsString.targetFreqLowCount.rawValue)
        let targetFreqHighCount = userDefaults.integer(forKey: SettingsString.targetFreqHighCount.rawValue)
        let distractorColorLowCount = userDefaults.integer(forKey: SettingsString.distractorColorLowCount.rawValue)
        let distractorColorHighCount = userDefaults.integer(forKey: SettingsString.distractorColorHighCount.rawValue)
        
        guard let groupString = groupStringOptional else { return nil }
        guard let group = ParticipantGroup(rawValue: groupString) else { return nil }
        guard let participant = participantOptional else { return nil }
        
        return StudySettings(participant: participant, group: group, rowCount: rowCount, columnCount: columnCount, itemDiameter: CGFloat(itemDiameter), itemDistance: CGFloat(itemDistance), practiceTrialCount: practiceTrialCount, targetFreqLowCount: targetFreqLowCount, targetFreqHighCount: targetFreqHighCount, distractorColorLowCount: distractorColorLowCount, distractorColorHighCount: distractorColorHighCount)
    }
    
    static func defaultSettingsForParticipant(_ participant: String) -> StudySettings {
        return StudySettings(participant: participant, group: Const.StudyParameters.group, rowCount: Const.StudyParameters.rowCount, columnCount: Const.StudyParameters.columnCount, itemDiameter: Const.StudyParameters.itemDiameter, itemDistance: Const.StudyParameters.itemDistance, practiceTrialCount: Const.StudyParameters.practiceTrialCount, targetFreqLowCount: Const.StudyParameters.targetFreqLowCount, targetFreqHighCount: Const.StudyParameters.targetFreqHighCount, distractorColorLowCount: Const.StudyParameters.distractorColorLowCount, distractorColorHighCount: Const.StudyParameters.distractorColorHighCount)
    }
}
