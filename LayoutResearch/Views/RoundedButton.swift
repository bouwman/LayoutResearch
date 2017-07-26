//
//  RoundedButton.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 23.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton {
    var identifier = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cornerRadius = frame.size.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        cornerRadius = frame.size.height / 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius
    }
    
    @IBInspectable var cornerRadius: CGFloat = 5 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

