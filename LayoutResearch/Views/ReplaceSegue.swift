//
//  ReplaceSegue.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 25.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

class ReplaceSegue: UIStoryboardSegue {
    override func perform() {
        let controllerToReplace = source.childViewControllers.first
        let destinationControllerView = destination.view
        
        destinationControllerView?.translatesAutoresizingMaskIntoConstraints = true
        destinationControllerView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        destinationControllerView?.frame = source.view.bounds
        
        controllerToReplace?.willMove(toParentViewController: nil)
        source.addChildViewController(destination)
        
        source.view.addSubview(destinationControllerView!)
        controllerToReplace?.view.removeFromSuperview()
        
        destination.didMove(toParentViewController: source)
        controllerToReplace?.removeFromParentViewController()
    }
}
