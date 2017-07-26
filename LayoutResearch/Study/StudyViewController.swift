//
//  StudyViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 25.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import ResearchKit

class StudyViewController: UIViewController {
    var resultService = ResultService()
    
    @IBOutlet weak var exportResultsButton: UIButton!
    
    @IBAction func didPressStart(_ sender: RoundedButton) {
        let layouts: [LayoutType] = [.grid, .horizontal, .vertical]
        let service = StudyService(layouts: layouts, organisation: .random, dimension: 5, itemDiameter: 50, itemDistance: 10, trialCount: 5, practiceTrialCount: 3)
        let task = ORKOrderedTask(identifier: "SearchTask-1", steps: service.steps)
        let taskVC = ORKTaskViewController(task: task, taskRun: nil)
        
        taskVC.delegate = self
        
        present(taskVC, animated: true, completion: nil)
    }
    
    @IBAction func exportResultsButtonPressed(_ sender: UIButton) {
        guard resultService.isResultAvailable else { return }
        
        present(createActivityViewControllerFor(items: [resultService.csvFilePath]), animated: true, completion: nil)
    }
    
    @IBAction func exportConsentFormPressed(_ sender: UIButton) {
        guard let consentPath = UserDefaults.standard.url(forKey: SettingsString.consentPath.rawValue) else { return }
        
        present(createActivityViewControllerFor(items: [consentPath]), animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exportResultsButton.isEnabled = resultService.isResultAvailable
    }
    
    private func createActivityViewControllerFor(items: [Any]) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .saveToCameraRoll,
            .postToFlickr,
            .postToVimeo,
            .postToTencentWeibo,
            .postToTwitter,
            .postToFacebook,
            .openInIBooks
        ]
        return activityVC
    }
}

extension StudyViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .completed:
            // Retrieve results
            let taskResults = taskViewController.result.results!
            var searchResults: [SearchResult] = []
            
            for result in taskResults {
                if let collectionResult = result as? ORKCollectionResult {
                    if let stepResults = collectionResult.results {
                        for stepResult in stepResults {
                            if let searchResult = stepResult as? SearchResult {
                                searchResults.append(searchResult)
                            }
                        }
                    }
                }
            }
            
            // Save results
            resultService.lastResults = searchResults
            
            // Activate export button
            exportResultsButton.isEnabled = resultService.isResultAvailable
            
            // Dismiss
            dismiss(animated: true, completion: nil)
        case .discarded, .failed, .saved:
            dismiss(animated: true, completion: nil)
        }
    }
        
    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        if let searchStep = step as? SearchStep {
            return SearchStepViewController(step: searchStep)
        } else if let searchDescriptionStep = step as? SearchDescriptionStep {
            return SearchDescriptionStepViewController(step: searchDescriptionStep)
        } else if let layoutIntroStep = step as? LayoutIntroStep {
            return LayoutIntroStepViewController(step: layoutIntroStep)
        } else if let introStep = step as? ORKInstructionStep {
            return ORKInstructionStepViewController(step: introStep)
        } else {
            return ORKActiveStepViewController(step: step)
        }
    }
}
