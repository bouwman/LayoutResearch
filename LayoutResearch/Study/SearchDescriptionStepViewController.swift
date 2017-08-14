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
        
        // Fade in button after 0.3 sec
//        nextButton?.isHidden = true
    }
//
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Fade in button after 1 sec
//        nextButton?.alpha = 0.0
//        nextButton?.isHidden = false
//        nextButton?.isUserInteractionEnabled = false
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
//            self.nextButton?.alpha = 1.0
//        }, completion: { completed in
//            self.nextButton?.isUserInteractionEnabled = true
//        })
//    }
}
