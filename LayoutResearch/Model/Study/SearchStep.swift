//
//  SearchStep.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 25.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import ResearchKit

class SearchStep: ORKActiveStep {
    var participantIdentifier: String
    var items: [[SearchItemProtocol]]
    var targetItem: SearchItemProtocol
    var targetFrequency: Int
    var layout: LayoutType
    var organisation: OrganisationType
    var itemDiameter: CGFloat
    var itemDistance: CGFloat
    var isPractice: Bool
    var activityNumber: Int
    
    init(identifier: String, participantIdentifier: String, items: [[SearchItemProtocol]], targetItem: SearchItemProtocol, targetFrequency: Int, layout: LayoutType, organisation: OrganisationType, itemDiameter: CGFloat, itemDistance: CGFloat, isPractice: Bool, activityNumber: Int) {
        self.participantIdentifier = participantIdentifier
        self.items = items
        self.targetItem = targetItem
        self.targetFrequency = targetFrequency
        self.layout = layout
        self.organisation = organisation
        self.itemDiameter = itemDiameter
        self.itemDistance = itemDistance
        self.isPractice = isPractice
        self.activityNumber = activityNumber
        
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var itemCount: Int {
        var counter = 0
        for itemsInRow in items {
            for _ in itemsInRow {
                counter += 1
            }
        }
        return counter
    }
    
    var sameColorCount: Int {
        var counter = 0
        for itemsInRow in items {
            for item in itemsInRow {
                if item.colorId == targetItem.colorId {
                    counter += 1
                }
            }
        }
        return counter
    }
}
