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
    var targetFrequency: Int
    var settings: StepSettings
    
    init(identifier: String, participantIdentifier: String, items: [[SearchItemProtocol]], targetFrequency: Int, settings: StepSettings) {
        self.participantIdentifier = participantIdentifier
        self.items = items
        self.targetFrequency = targetFrequency
        self.settings = settings
        
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
                if item.colorId == settings.targetItem.colorId {
                    counter += 1
                }
            }
        }
        return counter
    }
}
