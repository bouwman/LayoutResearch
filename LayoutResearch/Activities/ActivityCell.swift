//
//  ActivityCell.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 04.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            setColors(isActive: isUserInteractionEnabled, isSelected: false)
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        setColors(isActive: isUserInteractionEnabled, isSelected: highlighted)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        setColors(isActive: isUserInteractionEnabled, isSelected: selected)
    }
    
    func setColors(isActive: Bool, isSelected: Bool) {
        if isActive {
            if isSelected {
                backgroundColor = tintColor
                titleLabel?.textColor = UIColor.white
                detailLabel?.textColor = UIColor.white
                icon?.tintColor = UIColor.white
            } else {
                backgroundColor = UIColor.clear
                titleLabel?.textColor = tintColor
                titleLabel?.alpha = 1.0
                detailLabel?.alpha = 1.0
                icon?.alpha = 1.0
            }
        } else {
            titleLabel?.textColor = UIColor.black
            titleLabel?.alpha = 0.5
            detailLabel?.alpha = 0.5
            icon?.alpha = 0.5
        }
        detailLabel?.textColor = UIColor.black
        icon?.tintColor = UIColor.black
    }
}

