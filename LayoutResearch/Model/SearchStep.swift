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
    var layout: LayoutType
    var organisation: OrganisationType
    var itemDiameter: CGFloat
    var itemDistance: CGFloat
    var isPractice: Bool
    
    init(identifier: String, participantIdentifier: String, items: [[SearchItemProtocol]], targetItem: SearchItemProtocol, layout: LayoutType, organisation: OrganisationType, itemDiameter: CGFloat, itemDistance: CGFloat, isPractice: Bool) {
        self.participantIdentifier = participantIdentifier
        self.items = items
        self.targetItem = targetItem
        self.layout = layout
        self.organisation = organisation
        self.itemDiameter = itemDiameter
        self.itemDistance = itemDistance
        self.isPractice = isPractice
        
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
        return targetItem.sameColorCount
    }
}
