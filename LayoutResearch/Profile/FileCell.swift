//
//  FileCell.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 31.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

class FileCell: UITableViewCell {
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
                textLabel?.textColor = .white
            } else {
                backgroundColor = UIColor.clear
                textLabel?.textColor = tintColor
            }
        } else {
            textLabel?.textColor = UIColor.black
            textLabel?.alpha = 0.5
        }
    }
}
