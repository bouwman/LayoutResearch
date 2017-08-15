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
        introStep.title = "Win a £20 Amazon voucher"
        introStep.text = "To enter the prize draw for one of five £20 Amazon vouchers, enter your email address on the next page. By submitting your email address you agree with the terms and conditions below."
        introStep.footnote = "1. People who complete the study and submit their contact details will be entered into a prize draw to win one of five £20 Amazon vouchers.\n2. The closing date for entries to be received is 13 October 2017.\n3. The two winners will be drawn at random on 20 October 2017 from all eligible study participants that submitted their contact details.\n4. The winners will be notified within two weeks of the draw using the contact details provided on entry.\n5. A £20 Amazon voucher will be emailed to each winner within eight weeks of the draw date using the email address provided.\n6. No cash alternative will be given. Only one prize can be won per study participant.\n7. In order to be eligible to enter the prize draw, contact details must be provided.\n8. Personal information required for the prize draw will be used only for the purpose of the prize draw and will only be processed by the researchers conducting this study.\n9. The conductors of this study reserve the right to remove or change this prize draw at any time."
        
        // Steps
        let questionStep = ORKQuestionStep(identifier: Const.Identifiers.layoutSurveyStep, title: "Enter Email", text: "Type your email address to enter the prize draw.", answer: ORKEmailAnswerFormat())
        questionStep.isOptional = false
        
        let completeStep = ORKCompletionStep(identifier: "CompletionStep")
        completeStep.title = "Thank you!"
        completeStep.detailText = "The two winners will be drawn at random on 15 September 2017 and notified within two weeks of the draw."
        
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
