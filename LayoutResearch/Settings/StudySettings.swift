//
//  StudySettings.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 30.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

enum ParticipantGroup: String, CustomStringConvertible, SelectionPresentable {
    case a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x
    
    var layouts: [LayoutType] {
        switch self {
        case .a,.g,.m,.s:
            return [.grid, .horizontal, .vertical]
        case .b,.h,.n,.t:
            return [.grid, .vertical, .horizontal]
        case .c,.i,.o,.u:
            return [.horizontal, .grid, .vertical]
        case .d,.j,.p,.v:
            return [.vertical, .grid, .horizontal]
        case .e,.k,.q,.w:
            return [.vertical, .horizontal, .grid]
        case .f,.l,.r,.x:
            return [.horizontal, .vertical, .grid]
        }
    }
    
    var organisation: OrganisationType {
        switch self {
        case .a,.b,.c,.d,.e,.f,.m,.n,.o,.p,.q,.r:
            return .stable
        case .g,.h,.i,.j,.k,.l,.s,.t,.u,.v,.w,.x:
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
    
    static var allGroups: [ParticipantGroup] {
        return [.a,.b,.c,.d,.e,.f,.g,.h,.i,.j,.k,.l,.m,.n,.o,.p,.q,.r,.s,.t,.u,.v,.w,.x]
    }
    
    static var random: ParticipantGroup {
        return ParticipantGroup.allGroups[randomInt(min: 0, max: allGroups.count - 1)]
    }
    
    func targetItemsFrom(searchItems: [[SearchItemProtocol]]) -> [SearchItemProtocol] {
        let a,b,c,d,e,f,g,h,i,j : SearchItemProtocol
        switch self {
        case .a,.b,.c,.d,.e,.f,.g,.h,.i,.j,.k,.l:
            // Color distractor count high
            a = searchItems[2][1] // Blue
            b = searchItems[1][3] // Blue
            c = searchItems[4][3] // Orange
            d = searchItems[1][1] // Orange
            
            // Color distractor count low
            e = searchItems[3][2] // Dark green
            f = searchItems[2][2] // Dark green
            g = searchItems[4][1] // Dark blue
            h = searchItems[1][2] // Dark blue
            i = searchItems[5][1] // Green
            j = searchItems[0][2] // Green
        case .m,.n,.o,.p,.q,.r,.s,.t,.u,.v,.w,.x:
            // Color distractor count high
            a = searchItems[4][2] // Pink
            b = searchItems[5][2] // Pink
            c = searchItems[2][0] // Orange
            d = searchItems[3][1] // Orange
            
            // Color distractor count low
            e = searchItems[2][2] // Dark green
            f = searchItems[3][2] // Dark green
            g = searchItems[1][2] // Dark blue
            h = searchItems[4][1] // Dark blue
            i = searchItems[0][2] // Green
            j = searchItems[5][1] // Green
        }
        
        return [a, j, g, f, c, h, e, i, a, g, c, e, b, i, d, a, j, g, f, c, h, e, i, a, g, c, e, b, i, d]
    }
    
    func practiceTargetItemsFrom(searchItems: [[SearchItemProtocol]]) -> [SearchItemProtocol] {
        let a,b,c: SearchItemProtocol
        
        switch self {
        case .a,.b,.c,.d,.e,.f,.g,.h,.i,.j,.k,.l:
            a = searchItems[5][0] // Orange
            b = searchItems[0][0] // Blue
            c = searchItems[4][0] // Pink
        case .m,.n,.o,.p,.q,.r,.s,.t,.u,.v,.w,.x:
            a = searchItems[0][3] // Orange
            b = searchItems[3][0] // Pink
            c = searchItems[1][3] // Blue
        }
        
        return [a, b, c]
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
        let userIdOptional = userDefaults.string(forKey: SettingsString.icloudUserId.rawValue)
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
        
        let participantIdentifierOptional: String?
        if let userId = userIdOptional {
            participantIdentifierOptional = userId
        } else {
            participantIdentifierOptional = userDefaults.string(forKey: SettingsString.participantIdentifier.rawValue)
        }
        
        guard let groupString = groupStringOptional else { return nil }
        guard let group = ParticipantGroup(rawValue: groupString) else { return nil }
        guard let participant = participantIdentifierOptional else { return nil }
        
        return StudySettings(participant: participant, group: group, rowCount: rowCount, columnCount: columnCount, itemDiameter: CGFloat(itemDiameter), itemDistance: CGFloat(itemDistance), practiceTrialCount: practiceTrialCount, targetFreqLowCount: targetFreqLowCount, targetFreqHighCount: targetFreqHighCount, distractorColorLowCount: distractorColorLowCount, distractorColorHighCount: distractorColorHighCount)
    }
    
    static func defaultSettingsForParticipant(_ participant: String) -> StudySettings {
        return StudySettings(participant: participant, group: ParticipantGroup.random, rowCount: Const.StudyParameters.rowCount, columnCount: Const.StudyParameters.columnCount, itemDiameter: Const.StudyParameters.itemDiameter, itemDistance: Const.StudyParameters.itemDistance, practiceTrialCount: Const.StudyParameters.practiceTrialCount, targetFreqLowCount: Const.StudyParameters.targetFreqLowCount, targetFreqHighCount: Const.StudyParameters.targetFreqHighCount, distractorColorLowCount: Const.StudyParameters.distractorColorLowCount, distractorColorHighCount: Const.StudyParameters.distractorColorHighCount)
    }
}
