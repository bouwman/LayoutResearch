//
//  SearchDescriptionStep.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 25.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import ResearchKit

class SearchDescriptionStep: ORKActiveStep {
    var targetItem: SearchItemProtocol
    var targetDiameter: CGFloat
    
    init(identifier: String, targetItem: SearchItemProtocol, targetDiameter: CGFloat) {
        self.targetItem = targetItem
        self.targetDiameter = targetDiameter
        
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
