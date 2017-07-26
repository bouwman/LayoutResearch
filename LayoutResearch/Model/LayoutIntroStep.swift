//
//  LayoutIntroStep.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 26.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import ResearchKit

class LayoutIntroStep: ORKActiveStep {
    var items: [[SearchItemProtocol]]
    var layout: LayoutType
    var itemDiameter: CGFloat
    var itemDistance: CGFloat
    
    init(identifier: String, items: [[SearchItemProtocol]], layout: LayoutType, itemDiameter: CGFloat, itemDistance: CGFloat) {
        self.items = items
        self.layout = layout
        self.itemDiameter = itemDiameter
        self.itemDistance = itemDistance
        
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
