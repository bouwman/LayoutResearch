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
    var service: StudyService!
    
    @IBOutlet weak var exportResultsButton: UIButton!
    
    @IBAction func didPressStart(_ sender: RoundedButton) {
        let task = ORKOrderedTask(identifier: "SearchTask-1", steps: service.steps)
        let taskVC = ORKTaskViewController(task: task, taskRun: nil)
        
        taskVC.delegate = self
        
        present(taskVC, animated: true, completion: nil)
    }
    
    @IBAction func exportResultsButtonPressed(_ sender: UIButton) {
        guard resultService.fileService.isResultAvailable else { return }
        
        present(createActivityViewControllerFor(items: [resultService.fileService.csvFilePath]), animated: true, completion: nil)
    }
    
    @IBAction func exportConsentFormPressed(_ sender: UIButton) {
        guard let consentPath = UserDefaults.standard.url(forKey: SettingsString.consentPath.rawValue) else { return }
        
        present(createActivityViewControllerFor(items: [consentPath]), animated: true, completion: nil)
    }
    
    @IBAction func unwindToStudy(_ segue: UIStoryboardSegue) {
        // Settings vc gets dismissed
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            if let settingsVC = navVC.topViewController as? SettingsViewController {
                settingsVC.settings = service.settings
                settingsVC.delegate = self
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        service = StudyService(settings: loadSettings())
        
        exportResultsButton.isEnabled = resultService.fileService.isResultAvailable
    }
    
    private func loadSettings() -> StudySettings {
        if let savedSettings = StudySettings.fromUserDefaults(userDefaults: UserDefaults.standard) {
            return savedSettings
        } else {
            let settings = StudySettings(participant: UUID().uuidString, group: Const.StudyParameters.group, rowCount: Const.StudyParameters.rowCount, columnCount: Const.StudyParameters.columnCount, itemDiameter: Const.StudyParameters.itemDiameter, itemDistance: Const.StudyParameters.itemDistance, trialCount: Const.StudyParameters.trialCount, practiceTrialCount: Const.StudyParameters.practiceTrialCount)
            settings.saveToUserDefaults(userDefaults: UserDefaults.standard)
            return settings
        }
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
            exportResultsButton.isEnabled = resultService.fileService.isResultAvailable
            
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

extension StudyViewController: SettingsViewControllerDelegate {
    func settingsViewController(viewController: SettingsViewController, didChangeSettings settings: StudySettings) {
        service = StudyService(settings: settings)
    }
}