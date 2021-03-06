//
//  ActivityStateMachine.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 02.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import GameplayKit

class ActivityStateMachine: GKStateMachine {
    init(activityCell: ActivityCell? = nil) {
        let retrieve = RetrievingDataState()
        let dataAvailable = DataAvailableState()
        let dataNotAvailable = DataNotAvailableState()
        let upload = UploadingState()
        let uploadFailed = UploadFailedState()
        let uploadComplete = UploadCompleteState()
        let timeRemaining = TimeRemainingState()
        let unknown = UnknownState()
        
        retrieve.activityCell = activityCell
        dataAvailable.activityCell = activityCell
        dataNotAvailable.activityCell = activityCell
        upload.activityCell = activityCell
        uploadFailed.activityCell = activityCell
        uploadComplete.activityCell = activityCell
        timeRemaining.activityCell = activityCell
        unknown.activityCell = activityCell
        
        super.init(states: [retrieve, dataAvailable, dataNotAvailable, upload, uploadFailed, uploadComplete, timeRemaining, unknown])
        
        enter(UnknownState.self)
    }
}

class ActivityState: GKState {
    var activityCell : ActivityCell?
    
    override func update(deltaTime seconds: TimeInterval) {
        didEnter(from: nil)
    }
}

class RetrievingDataState: ActivityState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == DataAvailableState.self || stateClass == DataNotAvailableState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let cell = activityCell {
            cell.spinnerView?.startAnimating()
            cell.statusButton?.isHidden = true
            cell.detailLabel?.text = "Retrieving settings ..."
        }
    }
    
    override func willExit(to nextState: GKState) {
        if let cell = activityCell {
            cell.spinnerView?.stopAnimating()
        }
    }
}

class DataAvailableState: ActivityState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == UploadingState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let cell = activityCell {
            cell.statusButton?.isHidden = true
            cell.detailLabel?.text = "Ready to start"
        }
    }
    
    override func willExit(to nextState: GKState) {
        
    }
}

class DataNotAvailableState: ActivityState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == RetrievingDataState.self || stateClass == TimeRemainingState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let cell = activityCell {
            cell.statusButton?.isHidden = false
            cell.detailLabel?.text = "Server connection failed"
        }
    }
    
    override func willExit(to nextState: GKState) {
        if let cell = activityCell {
            cell.statusButton?.isHidden = true
        }
    }
}

class UploadingState: ActivityState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == UploadFailedState.self || stateClass == UploadCompleteState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let cell = activityCell {
            cell.spinnerView?.startAnimating()
            cell.statusButton?.isHidden = true
            cell.detailLabel?.text = "Uploading results ..."
        }
    }
    
    override func willExit(to nextState: GKState) {
        if let cell = activityCell {
            cell.spinnerView?.stopAnimating()
        }
    }
}

class UploadFailedState: ActivityState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == UploadingState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let cell = activityCell {
            cell.statusButton?.isHidden = false
            cell.detailLabel?.text = "Upload failed"
        }
    }
    
    override func willExit(to nextState: GKState) {
        if let cell = activityCell {
            cell.statusButton?.isHidden = true
        }
    }
}

class UploadCompleteState: ActivityState {    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == UploadingState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let cell = activityCell {
            cell.statusButton?.isHidden = true
            cell.detailLabel?.text = "Completed"
        }
    }
    
    override func willExit(to nextState: GKState) {
        
    }
}

class TimeRemainingState: ActivityState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == DataAvailableState.self || stateClass == RetrievingDataState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let cell = activityCell {
            cell.statusButton?.isHidden = true
            // Set status text with activity
        }
    }
    
    override func willExit(to nextState: GKState) {
        
    }
}

class UnknownState: ActivityState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == DataAvailableState.self ||
            stateClass == DataNotAvailableState.self ||
            stateClass == RetrievingDataState.self ||
            stateClass == UploadingState.self ||
            stateClass == UploadFailedState.self ||
            stateClass == UploadCompleteState.self ||
            stateClass == TimeRemainingState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let cell = activityCell {
            cell.statusButton?.isHidden = false
            cell.detailLabel?.text = "Unknow error"
        }
    }
    
    override func willExit(to nextState: GKState) {
        if let cell = activityCell {
            cell.statusButton?.isHidden = true
        }
    }
}

