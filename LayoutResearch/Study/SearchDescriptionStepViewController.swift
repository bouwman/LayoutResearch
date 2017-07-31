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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let searchStep = step as? SearchDescriptionStep else { return }
        
        let size = searchStep.targetDiameter
        let targetItem = searchStep.targetItem
        let button = RoundedButton(frame: CGRect(x: 0, y: Const.Interface.descriptionItemMargin, width: size, height: size))
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: Const.Interface.descriptionItemMargin + size))
        let inset = size / Const.Interface.iconInsetDiameterRatio
        
        button.identifier = targetItem.identifier
        button.backgroundColor = UIColor.searchColorFor(id: targetItem.colorId)
        button.setImage(UIImage.searchImageFor(id: targetItem.shapeId), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        
        contentView.addSubview(button)
        
        customView = contentView
    }
}
