//
//  LayoutIntroStepViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 26.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import ResearchKit

class LayoutIntroStepViewController: ORKActiveStepViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let layoutIntroStep = step as? LayoutIntroStep else { return }
        
        var topMargin = Const.Interface.introLayoutMargin
        if layoutIntroStep.layout == .vertical {
            topMargin -= layoutIntroStep.itemDistance
        } else if layoutIntroStep.layout == .horizontal {
            topMargin += layoutIntroStep.itemDistance
        }
        
        // Create view
        let searchView = SearchView(itemDiameter: layoutIntroStep.itemDiameter, distance: layoutIntroStep.itemDistance, layout: layoutIntroStep.layout, topMargin: topMargin, items: layoutIntroStep.items)
                
        customView = searchView
    }
}
