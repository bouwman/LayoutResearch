//
//  StudyViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 25.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import ResearchKit
/*
class StudyViewController: UIViewController {
    var resultService = ResultService()
    var remoteDataService = RemoteDataService()
    var settings: StudySettings!
    var stateMachine: StudyStateMachine!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var warningButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func didPressStart(_ sender: RoundedButton) {
        let service = StudyService(settings: settings)
        let task = ORKOrderedTask(identifier: "SearchTask-1", steps: service.steps)
        let taskVC = ORKTaskViewController(task: task, taskRun: nil)
        
        taskVC.delegate = self
        
        present(taskVC, animated: true, completion: nil)
    }
    
    @IBAction func didPressWarningButton(_ sender: UIButton) {
        if stateMachine.currentState is DataNotAvailableState {
            loadRemoteSettings()
        } else {
            uploadStudyResults()
        }
    }
    
    @IBAction func unwindToStudy(_ segue: UIStoryboardSegue) {
        // Settings vc gets dismissed
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            if let settingsVC = navVC.topViewController as? SettingsViewController {
                settingsVC.settings = settings
                settingsVC.delegate = self
            }
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        stateMachine = StudyStateMachine(studyViewController: self)
        
        settings = loadLocalSettings()
        
        if remoteDataService.isResultUploaded == false && resultService.fileService.areResultsAvailable {
            uploadStudyResults { (error) in
                if let _ = error {
                    self.stateMachine.enter(UploadingFailedState.self)
                } else {
                    self.loadRemoteSettings()
                }
            }
        } else {
            self.loadRemoteSettings()
        }
    }
    
    // MARK: - Private
    
    private func loadLocalSettings() -> StudySettings {
        if let savedSettings = StudySettings.fromUserDefaults(userDefaults: UserDefaults.standard) {
            return savedSettings
        } else {
            let settings = StudySettings.defaultSettingsForParticipant(UUID().uuidString)
            settings.saveToUserDefaults(userDefaults: UserDefaults.standard)
            return settings
        }
    }
    
    private func uploadStudyResults(_ completion: ((Error?)->())? = nil) {
        guard let resultPath = resultService.fileService.mostRecentResultPath else {
            stateMachine.enter(DataAvailableState.self)
            return
        }
        
        stateMachine.enter(UploadingState.self)
        remoteDataService.uploadStudyResults(participantGroup: settings.group, csvURL: resultPath, consentURL: resultService.fileService.consentPath) { (error) in
            DispatchQueue.main.async {
                if let completion = completion {
                    completion(error)
                } else {
                    if let _ = error {
                        self.stateMachine.enter(UploadingFailedState.self)
                    } else {
                        self.stateMachine.enter(DataAvailableState.self)
                    }
                }
            }
        }
    }
    
    func loadRemoteSettings() {
        guard resultService.isParticipantGroupAssigned == false else {
            self.stateMachine.enter(DataAvailableState.self)
            return
        }
        
        stateMachine.enter(RetrievingDataState.self)
        remoteDataService.fetchLastSettings { (lastGroup, record, userId, error) in
            DispatchQueue.main.async {
                if let lastGroup = lastGroup {
                    self.settings.group = lastGroup.next
                    self.settings.saveToUserDefaults(userDefaults: UserDefaults.standard)
                    self.remoteDataService.subscribeToSettingsChangesIfNotDoneYet(completion: { (error) in
                        // Optional, so ignore result
                    })
                    self.stateMachine.enter(DataAvailableState.self)
                } else {
                    self.stateMachine.enter(DataNotAvailableState.self)
                }
                if let userId = userId {
                    // Save user id locally
                    UserDefaults.standard.set(userId.recordName, forKey: SettingsString.icloudUserId.rawValue)
                }
            }
        }
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
            resultService.isParticipantGroupAssigned = true
            
            // Reset after completion of every task
            remoteDataService.isResultUploaded = true
            
            // Save last conducted study settings and study data to icloud
            uploadStudyResults()
            
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
        } else if let completionStep = step as? ORKCompletionStep {
            return ORKCompletionStepViewController(step: completionStep)
        } else {
            return ORKActiveStepViewController(step: step)
        }
    }
}

extension StudyViewController: SettingsViewControllerDelegate {
    func settingsViewController(viewController: SettingsViewController, didChangeSettings settings: StudySettings) {
        self.settings = settings
    }
}
*/
