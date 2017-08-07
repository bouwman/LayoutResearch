//
//  RewardService.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 07.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import ResearchKit

class RewardService: NSObject {
    var taskComletion: ((Bool) -> ())?
    
    var participantEmail: String? {
        return UserDefaults.standard.string(forKey: SettingsString.participantEmail.rawValue)
    }
    
    func startRewardTask(fromViewController: UIViewController, onCompletion completion: @escaping (Bool) -> ()) {
        taskComletion = completion
        
        // Intro
        let introStep = ORKInstructionStep(identifier: "IntroStep")
        introStep.title = "Introduction"
        introStep.text = "Thank you so much for completing this survey. "
        introStep.detailText = "1. People who complete the study and submit their contact details will be entered into a prize draw to win one of two £50 Amazon vouchers.\n2. The closing date for entries to be received is 8 September 2017.\n3. The two winners will be drawn at random on 15 September 2017 from all eligible surveys submitted.\n4. The winners will be notified within two weeks of the draw using the contact details provided on entry.\n5. A £50 Amazon voucher will be emailed to each winner within eight weeks of the draw date using the email address provided.\n6. No cash alternative will be given. Only one prize can be won per study participant.\n7. In order to be eligible to enter the prize draw, contact details must be provided.\n8. Personal information required for the prize draw will be used only for the purpose of the prize draw and will only be processed by the researchers conducting this study. 9. The conductors of this study reserve the right to remove or change this prize draw at any time."
        
        // Steps
        let questionStep = ORKQuestionStep(identifier: Const.Identifiers.layoutSurveyStep, title: "Contact Details", text: "Please enter your email address below to enter the prize draw.", answer: ORKEmailAnswerFormat())
        questionStep.isOptional = false
        
        let completeStep = ORKCompletionStep(identifier: "CompletionStep")
        completeStep.title = "Done!"
        completeStep.detailText = "Thank you for participating in this study."
        
        // Task
        let task = ORKOrderedTask(identifier: "SurveyTask", steps: [introStep, questionStep, completeStep])
        let taskVC = ORKTaskViewController(task: task, taskRun: nil)
        taskVC.delegate = self
        
        fromViewController.present(taskVC, animated: true, completion: nil)
    }
}

extension RewardService: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .completed:
            // Save result
            if let stepResult = taskViewController.result.stepResult(forStepIdentifier: Const.Identifiers.layoutSurveyStep) {
                if let questionResult = stepResult.results?.first as? ORKTextQuestionResult, let email = questionResult.textAnswer {
                    UserDefaults.standard.set(email, forKey: SettingsString.participantEmail.rawValue)
                }
            }
            
            if let completion = taskComletion {
                completion(true)
            }
        case .discarded, .failed, .saved:
            if let completion = taskComletion {
                completion(false)
            }
        }
        taskViewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
