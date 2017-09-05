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
    
    func startSurvey(fromViewController: UIViewController, onSurveyCompletion completion: @escaping (Bool) -> ()) {
        surveyCompletion = completion
        
        // Choices
        let imageHorizontal = ORKImageChoice(normalImage: #imageLiteral(resourceName: "survey choice horizontal"), selectedImage: #imageLiteral(resourceName: "survey choice horizontal selected"), text: "Hexagonal horizontal", value: NSString(string: "horizontal"))
        let imageGrid = ORKImageChoice(normalImage: #imageLiteral(resourceName: "survey choice grid"), selectedImage: #imageLiteral(resourceName: "survey choice grid selected"), text: "Hexagonal grid", value: NSString(string: "grid"))
        let imageFormat = ORKImageChoiceAnswerFormat(imageChoices: [imageGrid, imageHorizontal])
        
        // Steps
        let questionStep = ORKQuestionStep(identifier: Const.Identifiers.layoutSurveyStep, title: "Survey", text: "Which layout did you prefer?", answer: imageFormat)
        questionStep.isOptional = false
        
        let completeStep = ORKCompletionStep(identifier: "CompletionStep")
        completeStep.title = "Done!"
        completeStep.detailText = "Thank you for participating in this study."
        
        // Task
        let surveyTask = ORKOrderedTask(identifier: "SurveyTask", steps: [questionStep, completeStep])
        let surveyVC = ORKTaskViewController(task: surveyTask, taskRun: nil)
        surveyVC.delegate = self
        
        fromViewController.present(surveyVC, animated: true, completion: nil)
    }
}

extension SurveyService: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .completed:
            // Save result
            if let surveyResult = taskViewController.result.stepResult(forStepIdentifier: Const.Identifiers.layoutSurveyStep) {
                if let layoutChoice = surveyResult.results?.first as? ORKChoiceQuestionResult, let layoutName = layoutChoice.choiceAnswers?.first as? NSString {
                    UserDefaults.standard.set(layoutName as String, forKey: SettingsString.preferredLayout.rawValue)
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
