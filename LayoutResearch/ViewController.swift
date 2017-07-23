//
//  ViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 23.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let step = OR
        let task = ORKOrderedTask(identifier: "task", steps: [myStep])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

