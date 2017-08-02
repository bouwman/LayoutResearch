//
//  RemoteErrorViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 01.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

protocol RemoteErrorViewControllerDelegate {
    func didResolveError()
}

class RemoteErrorViewController: UIViewController {
    var delegate: RemoteErrorViewControllerDelegate?
    
    @IBAction func didPressTryAgainButton(_ sender: UIButton) {
        if RemoteDataService.isICloudContainerAvailable {
            delegate?.didResolveError()
        }
    }
}
