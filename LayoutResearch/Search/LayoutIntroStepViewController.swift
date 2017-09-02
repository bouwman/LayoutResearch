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
        let image: UIImage?
        switch layoutIntroStep.layout {
        case .vertical:
            topMargin -= layoutIntroStep.itemDistance
            image = #imageLiteral(resourceName: "Layout preview hex ver")
        case .horizontal:
            topMargin += layoutIntroStep.itemDistance
            image = #imageLiteral(resourceName: "Layout preview hex hor")
        case .grid:
            image = #imageLiteral(resourceName: "Layout preview grid")
        }
        
        // Create view
        let previewImageView = UIImageView(image: image)
        previewImageView.contentMode = .center
        
        customView = previewImageView
    }
}
