//
//  ActivitiesViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 04.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import GameplayKit
import ResearchKit

enum ActivityType {
    case searchIcons, survey
}
class StudyActivity {
    var startDate: Date
    var number: Int
    var type: ActivityType
    var stateMachine = ActivityStateMachine()
    
    init(startDate: Date, number: Int, type: ActivityType) {
        self.startDate = startDate
        self.number = number
        self.type = type
    }
    
    var isStartable: Bool {
        return timeRemaining <= 0
    }
    
    var daysRemaining: Int {
        return Int(timeRemaining) / (60*60*24)
    }
    
    var timeRemaining: TimeInterval {
        return startDate.timeIntervalSince(Date())
    }
    
    var timeRemainingString: String {
        let days = daysRemaining
        if days > 0 {
            return days == 1 ? "\(days) Day" : "\(days) Days"
        } else {
            return timeToString(time: timeRemaining)
        }
    }
    
    private func timeToString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

class ActivitiesViewController: UITableViewController {
    var service = ActivitiesService()
    var resultService = ResultService()
    var remoteDataService = RemoteDataService()
    var settings: StudySettings!
    var timer: Timer?
    var triedLoadingSettings = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        
        for (i, activity) in service.activities.enumerated() {
            if remoteDataService.isResultUploaded(resultNumber: activity.number) == false && resultService.fileService.areResultsAvailable {
                uploadResultsOf(activity: activity, forRow: i)
            } else if service.isParticipantGroupAssigned == false && activity.isStartable {
                loadRemoteSettingsFor(activity: activity, forRow: i)
            } else if service.isParticipantGroupAssigned && activity.isStartable  {
                activity.stateMachine.enter(DataAvailableState.self)
            } else if activity.isStartable == false {
                activity.stateMachine.enter(TimeRemainingState.self)
            }
        }
    }
    
    @objc func updateTimer() {
        var indexPathToReload: [IndexPath] = []
        
        for (i, activity) in service.activities.enumerated() {
            if activity.daysRemaining <= 0 && activity.timeRemaining > 0 {
                indexPathToReload.append(IndexPath(row: i, section: 0))
            }
        }
        
        tableView.reloadRows(at: indexPathToReload, with: .fade)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ActivitiesViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Const.Identifiers.activityCell) as? ActivityCell else { fatalError("dequeueReusableCell")}
        let activity = service.activities[indexPath.row]
        
        cell.isUserInteractionEnabled = activity.isStartable
        cell.titleLabel?.text = "Search task \(activity.number)"
        cell.detailLabel?.text = activity.isStartable ? "" : activity.timeRemainingString
        
        if let cellState = activity.stateMachine.currentState as? ActivityState {
            cellState.activityCell = cell
            activity.stateMachine.update(deltaTime: 1)
            cellState.activityCell = nil
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.activities.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activity = service.activities[indexPath.row]
        start(activity: activity)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - Private
    
    func start(activity: StudyActivity) {
        let studyService = StudyService(settings: settings)
        let task = ORKOrderedTask(identifier: "SearchTask-\(activity.number)", steps: studyService.steps)
        let taskVC = ORKTaskViewController(task: task, taskRun: nil)
        
        taskVC.delegate = self
        
        service.activeActivity = activity
        
        present(taskVC, animated: true, completion: nil)
    }
    
    func loadRemoteSettingsFor(activity: StudyActivity, forRow row: Int) {
        activity.stateMachine.enter(RetrievingDataState.self)
        remoteDataService.fetchLastSettings { (lastGroup, record, userId, error) in
            DispatchQueue.main.async {
                if let lastGroup = lastGroup {
                    self.settings.group = lastGroup.next
                    self.settings.saveToUserDefaults(userDefaults: UserDefaults.standard)
                    self.remoteDataService.subscribeToSettingsChangesIfNotDoneYet(completion: { (error) in
                        // Optional, so ignore result
                    })
                    activity.stateMachine.enter(DataAvailableState.self)
                } else {
                    activity.stateMachine.enter(DataNotAvailableState.self)
                }
                self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
                if let userId = userId {
                    // Save user id locally
                    UserDefaults.standard.set(userId.recordName, forKey: SettingsString.icloudUserId.rawValue)
                }
            }
        }
    }
    
    func uploadResultsOf(activity: StudyActivity, forRow row: Int) {
        activity.stateMachine.enter(UploadingState.self)
        remoteDataService.uploadStudyResult(resultNumber: activity.number, csvURL: resultService.fileService.existingResultsPaths[activity.number], completion: { (error) in
            if let _ = error {
                activity.stateMachine.enter(UploadFailedState.self)
            } else {
                activity.stateMachine.enter(UploadCompleteState.self)
            }
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        })
    }
    
    private func loadLocalSettings() -> StudySettings {
        if let savedSettings = StudySettings.fromUserDefaults(userDefaults: UserDefaults.standard) {
            return savedSettings
        } else {
            let settings = StudySettings.defaultSettingsForParticipant(UUID().uuidString)
            settings.saveToUserDefaults(userDefaults: UserDefaults.standard)
            return settings
        }
    }
    
    @IBAction func unwindToStudy(_ segue: UIStoryboardSegue) {
        // Settings vc gets dismissed
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            if let settingsVC = navVC.topViewController as? SettingsViewController {
                settingsVC.settings = settings
                settingsVC.delegate = self
            }
        }
    }

}

extension ActivitiesViewController: ORKTaskViewControllerDelegate {
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
            resultService.saveResultsToCSV(results: searchResults)
            service.isParticipantGroupAssigned = true
            
            let activity = service.activeActivity!
            
            // Reset after completion of every task
            remoteDataService.setIsResultUploadedFor(resultNumber: activity.number, isResultUploaded: false)
            
            // Save last conducted study settings and study data to icloud
            uploadResultsOf(activity: activity, forRow: service.activities.index(where: { $0 === activity})!)
            service.activeActivity = nil
            
            // Dismiss
            dismiss(animated: true, completion: nil)
        case .discarded, .failed, .saved:
            service.activeActivity = nil
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

extension ActivitiesViewController: SettingsViewControllerDelegate {
    func settingsViewController(viewController: SettingsViewController, didChangeSettings settings: StudySettings) {
        self.settings = settings
    }
}
