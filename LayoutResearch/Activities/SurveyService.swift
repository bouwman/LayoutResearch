//
//  SurveyService.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 07.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import ResearchKit

class SurveyService: NSObject {
    var surveyCompletion: ((Bool) -> ())?
    var preferredLayout: String? {
        return UserDefaults.standard.string(forKey: SettingsString.preferredLayout.rawValue)
    }
    var preferredDensity: String? {
        return UserDefaults.standard.string(forKey: SettingsString.preferredDensity.rawValue)
    }
    
    func startSurvey(fromViewController: UIViewController, onSurveyCompletion completion: @escaping (Bool) -> ()) {
        surveyCompletion = completion
        
        // Choices
        let imageHorizontal = ORKImageChoice(normalImage: #imageLiteral(resourceName: "survey choice horizontal"), selectedImage: #imageLiteral(resourceName: "survey choice horizontal selected"), text: "Hexagonal", value: NSString(string: "horizontal"))
        let imageGrid = ORKImageChoice(normalImage: #imageLiteral(resourceName: "survey choice grid"), selectedImage: #imageLiteral(resourceName: "survey choice grid selected"), text: "Grid", value: NSString(string: "grid"))
        let layoutFormat = ORKImageChoiceAnswerFormat(imageChoices: [imageGrid, imageHorizontal])
        
        let imageClose = ORKImageChoice(normalImage: #imageLiteral(resourceName: "survey choice close"), selectedImage: #imageLiteral(resourceName: "survey choice close selected"), text: "High density", value: NSString(string: "close"))
        let imageApart = ORKImageChoice(normalImage: #imageLiteral(resourceName: "survey choice apart"), selectedImage: #imageLiteral(resourceName: "survey choice apart selected"), text: "Low density", value: NSString(string: "apart"))
        let densityFormat = ORKImageChoiceAnswerFormat(imageChoices: [imageClose, imageApart])

        // Steps
        let layoutQuestionStep = ORKQuestionStep(identifier: Const.Identifiers.layoutSurveyStep, title: "Layout", text: "Which layout did you prefer?", answer: layoutFormat)
        let densityQuestionStep = ORKQuestionStep(identifier: Const.Identifiers.densitySurveyStep, title: "Density", text: "Which layout density would you prefer?", answer: densityFormat)

        layoutQuestionStep.isOptional = false
        densityQuestionStep.isOptional = false
        
        let completeStep = ORKCompletionStep(identifier: "CompletionStep")
        completeStep.title = "Done!"
        completeStep.detailText = "Thank you for participating in this study."
        
        // Task
        let surveyTask = ORKOrderedTask(identifier: "SurveyTask", steps: [densityQuestionStep, layoutQuestionStep, completeStep])
        let surveyVC = ORKTaskViewController(task: surveyTask, taskRun: nil)
        surveyVC.delegate = self
        
        fromViewController.present(surveyVC, animated: true, completion: nil)
    }
}

extension SurveyService: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .completed:
            // Save results
            let results = taskViewController.result
            if let layoutResult = results.stepResult(forStepIdentifier: Const.Identifiers.layoutSurveyStep) {
                if let layoutChoice = layoutResult.results?.first as? ORKChoiceQuestionResult, let layoutName = layoutChoice.choiceAnswers?.first as? NSString {
                    UserDefaults.standard.set(layoutName as String, forKey: SettingsString.preferredLayout.rawValue)
                }
            }
            if let densityResult = results.stepResult(forStepIdentifier: Const.Identifiers.densitySurveyStep) {
                if let densityChoice = densityResult.results?.first as? ORKChoiceQuestionResult, let layoutName = densityChoice.choiceAnswers?.first as? NSString {
                    UserDefaults.standard.set(layoutName as String, forKey: SettingsString.preferredDensity.rawValue)
                }
            }
            
            if let completion = surveyCompletion {
                completion(true)
            }
        case .discarded, .failed, .saved:
            if let completion = surveyCompletion {
                completion(false)
            }
        }
        taskViewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
