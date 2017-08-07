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
            if isUserInteractionEnabled {
                titleLabel?.alpha = 1.0
                detailLabel?.alpha = 1.0
                icon?.alpha = 1.0
                icon?.tintColor = tintColor
            } else {
                titleLabel?.alpha = 0.5
                detailLabel?.alpha = 0.5
                icon?.alpha = 0.5
                icon?.tintColor = UIColor.black
            }
        }
    }
}
