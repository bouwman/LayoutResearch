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
import UserNotifications

class ActivitiesViewController: UITableViewController {
    var service = ActivitiesService()
    var settings: StudySettings!
    var timer: Timer?
    var triedLoadingSettings = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Large title for iOS 11
        if #available(iOS 11.0, *) {
//            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Self sizing cells
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Pull to refresh
        refreshControl?.addTarget(self, action: #selector(ActivitiesViewController.handleRefresh(refreshControl:)), for: .valueChanged)
        
        // Load local settings
        settings = loadLocalSettings()
        
        // Register for notifications
        registerNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update activities
        updateAllActivities()
        
        // Start timer
        startUIUpdateTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stopUIUpateTimer()
    }
    
    // MARK: - IB actions
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        updateAllActivities()
        // Stop after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
            refreshControl.endRefreshing()
        })
    }
    
    @objc func updateTimer() {
        guard service.lastActivityNumber ?? 0 < service.activities.count else { return }
        var indexPathToReload: [IndexPath] = []
        
        for (i, activity) in service.activities.enumerated() {
            if activity.timeRemaining > 0 && activity.daysRemaining <= 0 {
                indexPathToReload.append(IndexPath(row: i, section: 0))
            } else if activity.timeRemaining < 0 {
                // Reset next row if countdown reaches 0 while other task is not completed
                let nextOrSecondActivityNumber = service.lastActivityNumber == nil ? 1 : service.lastActivityNumber! + 2
                if activity.number == nextOrSecondActivityNumber {
                    let oneDayBack = Calendar.current.date(byAdding: .hour, value: -18, to: Date(), wrappingComponents: false)!
                    service.setLastActivityDate(oneDayBack, forActivityNumber: service.lastActivityNumber)
                    updateAllActivities()
                } else if let number = service.lastActivityNumber, activity.number == number {
                    // Always update row of current activity
                    indexPathToReload.append(IndexPath(row: i, section: 0))
                }
            }
        }
        
        tableView.reloadRows(at: indexPathToReload, with: .none)
    }

    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Const.Identifiers.activityCell) as? ActivityCell else { fatalError("dequeueReusableCell")}
        let activity = service.activities[indexPath.row]
        
        cell.isUserInteractionEnabled = activity.isStartable
        cell.titleLabel?.text = activity.description
        cell.detailLabel?.text = activity.isStartable ? "" : activity.timeRemainingString
        cell.icon.image = UIImage(named: activity.type.iconName)
        
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
        tableView.deselectRow(at: indexPath, animated: true)
        let activity = service.activities[indexPath.row]
        start(activity: activity)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    // MARK: - Helper
    
    func start(activity: StudyActivity) {
        switch activity.type {
        case .search:
            let studyService = StudyService(settings: settings, activityNumber: activity.number)
            let task = ORKOrderedTask(identifier: "SearchTask-\(activity.number)", steps: studyService.steps)
            let taskVC = ORKTaskViewController(task: task, taskRun: nil)
            
            taskVC.delegate = self
            
            service.activeActivity = activity
            
            present(taskVC, animated: true, completion: nil)
        case .survey:
            service.surveyService.startSurvey(fromViewController: self, onSurveyCompletion: { (completed) in
                self.updateAllActivities()
            })
        case .reward:
            service.rewardService.startRewardTask(fromViewController: self, onCompletion: { (completed) in
                self.updateAllActivities()
            })
        }
    }
    
    func updateAllActivities() {
        for (i, activity) in service.activities.enumerated() {
            switch activity.type {
            case .search:
                let isUploaded = service.remoteDataService.isSearchResultUploaded(resultNumber: activity.number)
                let resultExists = service.resultService.fileService.resultFileExists(resultNumber: activity.number)
                
                if resultExists {
                    if isUploaded {
                        activity.stateMachine.enter(UploadCompleteState.self)
                        self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    } else {
                        uploadResultsOf(activity: activity, forRow: i)
                    }
                } else {
                    if activity.timeRemaining <= 0 {
                        if service.isParticipantGroupAssigned {
                            activity.stateMachine.enter(DataAvailableState.self)
                            self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                        } else {
                            loadRemoteSettingsFor(activity: activity, forRow: i)
                        }
                    } else {
                        activity.stateMachine.enter(TimeRemainingState.self)
                        self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                    }
                }
            case .survey:
                if service.remoteDataService.isSurveyResultUploaded {
                    activity.stateMachine.enter(UploadCompleteState.self)
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                } else if service.surveyService.preferredLayout != nil {
                    uploadResultsOf(activity: activity, forRow: i)
                } else {
                    activity.stateMachine.enter(TimeRemainingState.self)
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                }
            case .reward:
                if service.remoteDataService.isParticipantsEmailUploaded {
                    activity.stateMachine.enter(UploadCompleteState.self)
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                } else if service.rewardService.participantEmail != nil {
                    uploadResultsOf(activity: activity, forRow: i)
                } else {
                    activity.stateMachine.enter(TimeRemainingState.self)
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                }
            }
        }
    }
    
    func loadRemoteSettingsFor(activity: StudyActivity, forRow row: Int) {
        guard service.isParticipantGroupAssigned == false else {
            activity.stateMachine.enter(DataAvailableState.self)
            return
        }
        
        activity.stateMachine.enter(RetrievingDataState.self)
        service.remoteDataService.fetchLastSettings { (lastGroup, lastTargetGroup, record, userId, error) in
            DispatchQueue.main.async {
                if let lastGroup = lastGroup, let lastTargetGroup = lastTargetGroup {
                    self.settings.group = lastGroup.next()
                    self.settings.targetGroup = lastTargetGroup.next()
                    self.settings.saveToUserDefaults(userDefaults: UserDefaults.standard)
                    self.service.remoteDataService.subscribeToSettingsChangesIfNotDoneYet(completion: { (error) in
                        // Optional, so ignore result
                    })
                    activity.stateMachine.enter(DataAvailableState.self)
                } else {
                    activity.stateMachine.enter(DataNotAvailableState.self)
                }
                self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                if let userId = userId {
                    // Save user id locally
                    UserDefaults.standard.set(userId.recordName, forKey: SettingsString.icloudUserId.rawValue)
                }
            }
        }
    }
    
    func uploadResultsOf(activity: StudyActivity, forRow row: Int) {
        activity.stateMachine.enter(UploadingState.self)
        
        switch activity.type {
        case .search:
            service.remoteDataService.uploadStudyResult(resultNumber: activity.number, group: settings.group, targetGroup: settings.targetGroup, csvURL: self.service.resultService.fileService.existingResultsPaths[activity.number], completion: { (error) in
                    self.updateUploadStateOf(activity: activity, atRow: row, afterError: error)
            })
        case .survey:
            if let preferredLayout = service.surveyService.preferredLayout {
                service.remoteDataService.uploadSurveyResult(preferredLayout: preferredLayout, completion: { (error) in
                    self.updateUploadStateOf(activity: activity, atRow: row, afterError: error)
                })
            }
        case .reward:
            if let email = service.rewardService.participantEmail {
                service.remoteDataService.uploadEmail(participantsEmail: email, completion: { (error) in
                    self.updateUploadStateOf(activity: activity, atRow: row, afterError: error)
                })
            }
        }
    }
    
    private func updateUploadStateOf(activity: StudyActivity, atRow row: Int, afterError error: Error?) {
        DispatchQueue.main.async {
            if let _ = error {
                activity.stateMachine.enter(UploadFailedState.self)
            } else {
                activity.stateMachine.enter(UploadCompleteState.self)
            }
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        }
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
    
    private func registerNotifications() {
        let application = UIApplication.shared
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[[.alert, .sound, .badge]], completionHandler: { (granted, error) in
                if granted {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                        UNUserNotificationCenter.current().delegate = NotificationHandler.sharedInstance
                    }
                }
            })
        } else if #available(iOS 9.0, *) {
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    func createNewNotificationFor(activity: StudyActivity) {
        guard activity.timeRemaining >= 0 else { return }
        
        let title = "New activity available"
        let body = "The next activity for the study is due. Please perform this activity within the next few hours."
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.badge = 1
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: activity.timeRemaining, repeats: false)
            let request = UNNotificationRequest(identifier: activity.identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                // Does not matter if successful
            })
        } else {
            let notification = UILocalNotification()
            notification.fireDate = activity.startDate
            notification.alertTitle = title
            notification.alertBody = body
            notification.applicationIconBadgeNumber = 1
            notification.soundName = UILocalNotificationDefaultSoundName
            
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    func startUIUpdateTimer() {
        // Create timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ActivitiesViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopUIUpateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController {
            if let settingsVC = navVC.childViewControllers.first as? SettingsViewController {
                settingsVC.settings = settings
                settingsVC.delegate = self
            }
        }
    }
    
    @IBAction func unwindToStudy(_ segue: UIStoryboardSegue) {
        // Settings vc gets dismissed
    }
}

// MARK: - ORKTaskViewControllerDelegate

extension ActivitiesViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .completed, .discarded:
            // Retrieve results
            let taskResults = taskViewController.result.results!
            let activity = service.activeActivity!
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
            service.resultService.saveSearchResultToCSV(resultNumber: activity.number, results: searchResults)
            service.resultService.saveAvgSearchTimesFor(resultNumber: activity.number, results: searchResults)
            service.isParticipantGroupAssigned = true
            
            // Reset after completion of every task
            service.remoteDataService.setIsResultUploadedFor(resultNumber: activity.number, isResultUploaded: false)
            
            // Recreate activities to suite current data
            service.lastActivityNumber = activity.number
            service.setLastActivityDate(Date(), forActivityNumber: activity.number)
            service.activeActivity = nil
            
            // Create reminder
            createNewNotificationFor(activity: activity)
            
            updateAllActivities()
            
            // Dismiss
            dismiss(animated: true, completion: nil)
        case .failed, .saved:
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

// MARK: - SettingsViewControllerDelegate

extension ActivitiesViewController: SettingsViewControllerDelegate {
    func settingsViewController(viewController: SettingsViewController, didChangeSettings settings: StudySettings) {
        self.settings = settings
    }
}

// MARK: - UIScrollViewDelegate

extension ActivitiesViewController {
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopUIUpateTimer()
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startUIUpdateTimer()
    }
}
