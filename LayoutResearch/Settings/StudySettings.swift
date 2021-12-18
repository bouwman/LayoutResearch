//
//  StudySettings.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 30.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

enum ParticipantGroup: String, CustomStringConvertible, SelectionPresentable {
    case a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p
    
    var layouts: [LayoutType] {
        switch self {
        case .a,.c,.e,.g,.i,.k,.m,.o:
            return [.grid, .horizontal]
        case .b,.d,.f,.h,.j,.l,.n,.p:
            return [.horizontal, .grid]
        }
    }
    
    var organisation: OrganisationType {
        switch self {
        case .a,.b,.e,.f,.i,.j,.m,.n:
            return .stable
        case .c,.d,.g,.h,.k,.l,.o,.p:
            return .random
        }
    }
    
    var itemDistance: ItemDistance {
        switch self {
        case .a,.b,.c,.d,.i,.j,.k,.l:
            return .standard
        case .e,.f,.g,.h,.m,.n,.o,.p:
            return .fix(1)
        }
    }
    
    var isDesignedLayout: Bool {
        switch self {
        case .a,.b,.c,.d,.e,.f,.g,.h:
            return true
        case .i,.j,.k,.l,.m,.n,.o,.p:
            return false
        }
    }
    
    var description: String {
        return "Group \(self.rawValue.uppercased())"
    }
    
    var title: String {
        return description
    }
    
    func next() -> ParticipantGroup {
        let currentIndex = ParticipantGroup.allGroups.firstIndex(of: self)!
        if currentIndex == ParticipantGroup.allGroups.count - 1 {
            return ParticipantGroup.allGroups.first!
        } else {
            return ParticipantGroup.allGroups[currentIndex + 1]
        }
    }
    
    static var allGroups: [ParticipantGroup] {
        return [.a,.b,.c,.d,.e,.f,.g,.h,.i,.j,.k,.l,.m,.n,.o,.p]
    }
    
    static var mandatoryGroups: [ParticipantGroup] {
        return [.a,.b,.c,.d,.e,.f,.g,.h]
    }
    
    static var optionalGroups: [ParticipantGroup] {
        return [.i,.j,.k,.l,.m,.n,.o,.p]
    }
    
    static var random: ParticipantGroup {
        return ParticipantGroup.allGroups[randomInt(min: 0, max: allGroups.count - 1)]
    }
    
    static var randomMandatory: ParticipantGroup {
        return ParticipantGroup.mandatoryGroups[randomInt(min: 0, max: mandatoryGroups.count - 1)]
    }
    
    func targetItemsFrom(searchItems: [[SearchItemProtocol]]) -> [SearchItemProtocol] {
        let a,b,c,d,e,f,g,h,i,j : SearchItemProtocol
        
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
        
        /*
        switch self {
        case .a,.b,.c,.d,.e,.f,.g,.h:
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
        case .i,.j,.k,.l,.m,.n,.o,.p:
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
         */
        
        return [a, j, g, f, c, h, e, i, a, g, c, e, b, i, d, a, j, g, f, c, h, e, i, a, g, c, e, b, i, d]
    }
    
    func practiceTargetItemsFrom(searchItems: [[SearchItemProtocol]]) -> [SearchItemProtocol] {
        let a,b,c: SearchItemProtocol
        
        switch self {
        case .a,.b,.c,.d,.e,.f,.g,.h:
            a = searchItems[5][0] // Orange
            b = searchItems[0][0] // Blue
            c = searchItems[4][0] // Pink
        case .i,.j,.k,.l,.m,.n,.o,.p:
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
    var practiceTrialCount: Int
    var targetFreqLowCount: Int
    var targetFreqHighCount: Int
    var distractorColorLowCount: Int
    var distractorColorHighCount: Int
    
    func saveToUserDefaults(userDefaults: UserDefaults) {
        userDefaults.set(participant, forKey: SettingsString.participantIdentifier.rawValue)
        userDefaults.set(group.rawValue, forKey: SettingsString.participantGroup.rawValue)
        userDefaults.set(itemDiameter, forKey: SettingsString.layoutItemDiameter.rawValue)
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
        let participantIdentifierOptional = userDefaults.string(forKey: SettingsString.participantIdentifier.rawValue)
        let groupStringOptional = userDefaults.string(forKey: SettingsString.participantGroup.rawValue)
        let rowCount = userDefaults.integer(forKey: SettingsString.layoutRowCount.rawValue)
        let columnCount = userDefaults.integer(forKey: SettingsString.layoutColumnCount.rawValue)
        let itemDiameter = userDefaults.float(forKey: SettingsString.layoutItemDiameter.rawValue)
        let practiceTrialCount = userDefaults.integer(forKey: SettingsString.practiceTrialCount.rawValue)
        let targetFreqLowCount = userDefaults.integer(forKey: SettingsString.targetFreqLowCount.rawValue)
        let targetFreqHighCount = userDefaults.integer(forKey: SettingsString.targetFreqHighCount.rawValue)
        let distractorColorLowCount = userDefaults.integer(forKey: SettingsString.distractorColorLowCount.rawValue)
        let distractorColorHighCount = userDefaults.integer(forKey: SettingsString.distractorColorHighCount.rawValue)
        
        guard let groupString = groupStringOptional else { return nil }
        guard let group = ParticipantGroup(rawValue: groupString) else { return nil }
        guard let participant = participantIdentifierOptional else { return nil }
        
        return StudySettings(participant: participant, group: group, rowCount: rowCount, columnCount: columnCount, itemDiameter: CGFloat(itemDiameter), practiceTrialCount: practiceTrialCount, targetFreqLowCount: targetFreqLowCount, targetFreqHighCount: targetFreqHighCount, distractorColorLowCount: distractorColorLowCount, distractorColorHighCount: distractorColorHighCount)
    }
    
    static func defaultSettingsForParticipant(_ participant: String) -> StudySettings {
        return StudySettings(participant: participant, group: ParticipantGroup.random, rowCount: Const.StudyParameters.rowCount, columnCount: Const.StudyParameters.columnCount, itemDiameter: Const.StudyParameters.itemDiameter, practiceTrialCount: Const.StudyParameters.practiceTrialCount, targetFreqLowCount: Const.StudyParameters.targetFreqLowCount, targetFreqHighCount: Const.StudyParameters.targetFreqHighCount, distractorColorLowCount: Const.StudyParameters.distractorColorLowCount, distractorColorHighCount: Const.StudyParameters.distractorColorHighCount)
    }
}
