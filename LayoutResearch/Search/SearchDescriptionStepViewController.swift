//
//  SearchDescriptionStepViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 25.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import ResearchKit

class SearchDescriptionStepViewController: ORKActiveStepViewController {
    var nextButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let searchStep = step as? SearchDescriptionStep else { return }
        
        let topMargin = topMarginFor(layout: searchStep.settings.layout, itemDistance: searchStep.settings.itemDistance)
        let estimatedLayoutHeight = 6 * (searchStep.settings.itemDiameter + searchStep.settings.itemDistance)
        let yPosition = topMargin + CGFloat(searchStep.settings.targetDescriptionPosition) * estimatedLayoutHeight / 2.8
        
        let size = searchStep.settings.itemDiameter
        let targetItem = searchStep.settings.targetItem
        let button = RoundedButton(frame: CGRect(x: 0, y: yPosition, width: size, height: size))
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: yPosition + size))
        let inset = size / Const.Interface.iconInsetDiameterRatio
        
        button.identifier = targetItem.identifier
        button.backgroundColor = UIColor.searchColorFor(id: targetItem.colorId)
        button.setImage(UIImage.searchImageFor(id: targetItem.shapeId), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        contentView.addSubview(button)
        
        customView = contentView
        
        // Find next button
        for subview in self.view.subviews {
            for subview1 in subview.subviews {
                for subview2 in subview1.subviews {
                    for subview3 in subview2.subviews {
                        if let button = subview3 as? UIButton {
                            nextButton = button
                        }
                    }
                }
            }
        }
    }
}
