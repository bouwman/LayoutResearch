//
//  ViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 23.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import ResearchKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        let introStep = ORKInstructionStep(identifier: "intro")
        
        introStep.title = "Welcome to ResearchKit"
        
        let searchStep = SearchStep(identifier: "asdf")
        
        let task = ORKOrderedTask(identifier: "task", steps: [introStep, searchStep])
        
        
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        let taskResult = taskViewController.result
        // You could do something with the result here.
        
        // Then, dismiss the task view controller.
        dismiss(animated: true, completion: nil)
    }
}
class SearchStep: ORKStep {
    override init(identifier: String) {
        super.init(identifier: identifier)
        
        title = "Search"
        text = "Search this item"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
