//
//  IntroductionLayoutViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 03.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

class IntroductionLayoutViewController: UIViewController {
    
    let searchView = SearchView(itemDiameter: 42, distance: 7, layout: .horizontal, topMargin: 0, items: SearchView.createDefaultItems())

    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var centerViewWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerView.addSubview(searchView)
        
        centerViewWidth.constant = searchView.intrinsicContentSize.width
    }
}
