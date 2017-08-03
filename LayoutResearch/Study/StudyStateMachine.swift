//
//  StudyStateMachine.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 02.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import GameplayKit

class StudyStateMachine: GKStateMachine {
    init(studyViewController: StudyViewController) {
        let retrieve = RetrievingDataState()
        let dataAvailable = DataAvailableState()
        let dataNotAvailable = DataNotAvailableState()
        let upload = UploadingState()
        let uploadFailed = UploadingFailedState()
        
        retrieve.studyViewController = studyViewController
        dataAvailable.studyViewController = studyViewController
        dataNotAvailable.studyViewController = studyViewController
        upload.studyViewController = studyViewController
        uploadFailed.studyViewController = studyViewController
        
        super.init(states: [retrieve, dataAvailable, dataNotAvailable, upload, uploadFailed])
    }
}
class RetrievingDataState: GKState {
    var studyViewController : StudyViewController?
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == DataAvailableState.self || stateClass == DataNotAvailableState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let vc = studyViewController {
            vc.startButton?.isEnabled = false
            vc.activityIndicator?.startAnimating()
            vc.warningButton?.isHidden = true
            vc.stateLabel?.isHidden = false
            vc.stateLabel?.text = "Retrieving study settings ..."        }
    }
    
    override func willExit(to nextState: GKState) {
        if let vc = studyViewController {
            vc.activityIndicator?.stopAnimating()
        }
    }
}

class DataAvailableState: GKState {
    var studyViewController : StudyViewController?
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == UploadingState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let vc = studyViewController {
            vc.startButton?.isEnabled = true
            vc.warningButton?.isHidden = true
            vc.stateLabel?.isHidden = true
        }
    }
    
    override func willExit(to nextState: GKState) {
        
    }
}

class DataNotAvailableState: GKState {
    var studyViewController : StudyViewController?
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == RetrievingDataState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let vc = studyViewController {
            vc.startButton?.isEnabled = false
            vc.warningButton?.isHidden = false
            vc.stateLabel?.isHidden = false
            vc.stateLabel?.text = "You need to be connected to the internet to start this study."
        }
    }
    
    override func willExit(to nextState: GKState) {
        
    }
}

class UploadingState: GKState {
    var studyViewController : StudyViewController?
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == UploadingFailedState.self || stateClass == DataAvailableState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let vc = studyViewController {
            vc.startButton?.isEnabled = false
            vc.activityIndicator?.startAnimating()
            vc.warningButton?.isHidden = true
            vc.stateLabel?.isHidden = false
            vc.stateLabel?.text = "Uploading results ..."
        }
    }
    
    override func willExit(to nextState: GKState) {
        if let vc = studyViewController {
            vc.activityIndicator?.stopAnimating()
        }
    }
}

class UploadingFailedState: GKState {
    var studyViewController : StudyViewController?
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == UploadingState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let vc = studyViewController {
            vc.startButton?.isEnabled = false
            vc.warningButton?.isHidden = false
            vc.stateLabel?.isHidden = false
            vc.stateLabel?.text = "Uploading study results failed. Press the warning icon above to try again."
        }
    }
    
    override func willExit(to nextState: GKState) {
        
    }
}
