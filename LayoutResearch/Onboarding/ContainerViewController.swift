//
//  ContainerViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 23.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import ResearchKit

class ContainerViewController: UIViewController {

    // MARK: Properties
    
    var contentHidden = false {
        didSet {
            guard contentHidden != oldValue && isViewLoaded else { return }
            childViewControllers.first?.view.isHidden = contentHidden
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isParticipating = UserDefaults.standard.bool(forKey: SettingsString.isParticipating.rawValue)
        
        if isParticipating {
            toStudy()
        }
        else {
            toOnboarding()
        }
    }
    
    // MARK: Unwind segues
    
    @IBAction func unwindToStudy(_ segue: UIStoryboardSegue) {
        toStudy()
    }
    
    @IBAction func unwindToWithdrawl(_ segue: UIStoryboardSegue) {
        toWithdrawl()
    }
    
    // MARK: Transitions
    
    func toOnboarding() {
        performSegue(withIdentifier: "toOnboarding", sender: self)
    }
    
    func toStudy() {
        performSegue(withIdentifier: "toStudy", sender: self)
    }
    
    func toWithdrawl() {
        let viewController = WithdrawViewController()
        viewController.delegate = self
        
        present(viewController, animated: true, completion: nil)
    }
}

extension ContainerViewController: ORKTaskViewControllerDelegate {
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        // Check if the user has finished the `WithdrawViewController`.
        if taskViewController is WithdrawViewController {
            /*
             If the user has completed the withdrawl steps, remove them from
             the study and transition to the onboarding view.
             */
            if reason == .completed {
                UserDefaults.standard.set(false, forKey: SettingsString.isParticipating.rawValue)
                toOnboarding()
            }
            
            // Dismiss the `WithdrawViewController`.
            dismiss(animated: true, completion: nil)
        }
    }
}

