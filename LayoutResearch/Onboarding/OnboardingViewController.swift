/*
Copyright (c) 2015, Apple Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3.  Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit
import ResearchKit

class OnboardingViewController: UIViewController {
    
    let consentDocument = ConsentDocument()
    let fileService = LocalDataService()
    
    // MARK: IB actions
    
    @IBAction func joinButtonTapped(_ sender: UIButton) {
        let numberAnswer = ORKNumericAnswerFormat(style: .integer, unit: nil, minimum: 1, maximum: 99)
        let genderTexts = [ORKTextChoice(text: "Male", value: "Male" as NSString), ORKTextChoice(text: "Female", value: "Female" as NSString), ORKTextChoice(text: "Non-binary/ third gender", value: "Non-binary/ third gender" as NSString), ORKTextChoice(text: "Prefer not to say", value: "Prefer not to say" as NSString)]
        let textChoiceAnswer = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: genderTexts)
        let ageItem = ORKFormItem(identifier: Const.Identifiers.eligibilityItemAge, text: "How old are you?", answerFormat: numberAnswer)
        let genderItem = ORKFormItem(identifier: Const.Identifiers.eligibilityItemGender, text: "What is your gender?", answerFormat: textChoiceAnswer)
        
        ageItem.isOptional = false
        genderItem.isOptional = false
        
        let eligibilityStep = ORKFormStep(identifier: Const.Identifiers.eligibilityStep)
        eligibilityStep.formItems = [ageItem, genderItem]
        eligibilityStep.isOptional = false
        
        // Consent
        let consentStep = ORKVisualConsentStep(identifier: Const.Identifiers.visualConsentStep, document: consentDocument)
        let participantSignature = consentDocument.signatures!.first!
        let reviewConsentStep = ORKConsentReviewStep(identifier: Const.Identifiers.consetReviewStep, signature: participantSignature, in: consentDocument)
        
        reviewConsentStep.text = "Sign the consent form."
        reviewConsentStep.reasonForConsent = "Consent to join the Visual search in circular icon arrangements study."
        
        // Thank you
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = "Welcome aboard."
        completionStep.text = "Thank you for joining this study."
        let notEligibleStep = ORKCompletionStep(identifier: "NotEligibleStep")
        notEligibleStep.title = "Sorry"
        notEligibleStep.text = "Thank you for your interest in our study. Unfortunately you are not eligible to take part in this study. You must be be over 18."
        
        // Predicates
        let ageSelector = ORKResultSelector(stepIdentifier: eligibilityStep.identifier, resultIdentifier: ageItem.identifier)
        let ageOK = ORKResultPredicate.predicateForNumericQuestionResult(with: ageSelector, minimumExpectedAnswerValue: 18)
        let ageNotOK = ORKResultPredicate.predicateForNumericQuestionResult(with: ageSelector, maximumExpectedAnswerValue: 17)
        
        // Rules
        let eligibilityRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [(ageOK, reviewConsentStep.identifier), (ageNotOK, notEligibleStep.identifier)], defaultStepIdentifierOrNil: nil)
        let endAfterNotEligibleRule = ORKDirectStepNavigationRule(destinationStepIdentifier: "")
        
        // Task
        let orderedTask = ORKNavigableOrderedTask(identifier: "Join", steps: [consentStep, eligibilityStep, notEligibleStep, reviewConsentStep, completionStep])
        
        orderedTask.setNavigationRule(eligibilityRule, forTriggerStepIdentifier: eligibilityStep.identifier)
        orderedTask.setNavigationRule(endAfterNotEligibleRule, forTriggerStepIdentifier: notEligibleStep.identifier)
        
        let taskViewController = ORKTaskViewController(task: orderedTask, taskRun: nil)
        taskViewController.delegate = self
        
        present(taskViewController, animated: true, completion: nil)
    }
}

extension OnboardingViewController : ORKTaskViewControllerDelegate {
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
            case .completed:
                let result = taskViewController.result
                if let consentStepResult = result.stepResult(forStepIdentifier: Const.Identifiers.consetReviewStep),
                    let signatureResult = consentStepResult.results?.first as? ORKConsentSignatureResult {
                    
                    // Add signatures
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .none
                    let researcherSignature = ORKConsentSignature(forPersonWithTitle: "Researcher", dateFormatString: nil, identifier: "ResearcherSignature", givenName: "Tassilo", familyName: "Bouwman", signatureImage: #imageLiteral(resourceName: "Signature"), dateString: dateFormatter.string(from: Date()))
                    signatureResult.apply(to: consentDocument)
                    consentDocument.signatures?.append(researcherSignature)
                    
                    // Save pdf
                    consentDocument.makePDF(completionHandler: { (data, error) in
                        self.fileService.saveConsent(data: data)
                    })
                    
                    // Save name
                    UserDefaults.standard.set(signatureResult.signature?.familyName, forKey: SettingsString.participantFamilyName.rawValue)
                    UserDefaults.standard.set(signatureResult.signature?.givenName, forKey: SettingsString.participantGivenName.rawValue)
                    
                    // Save age
                    if let eligibilityStepResult = result.stepResult(forStepIdentifier: Const.Identifiers.eligibilityStep), let eligibilityResults = eligibilityStepResult.results {
                        for eligibilityResult in eligibilityResults {
                            if eligibilityResult.identifier == Const.Identifiers.eligibilityItemAge, let ageResult = eligibilityResult as? ORKNumericQuestionResult {
                                UserDefaults.standard.set(ageResult.numericAnswer!, forKey: SettingsString.participantAge.rawValue)
                            }
                            if eligibilityResult.identifier == Const.Identifiers.eligibilityItemGender, let genderResult = eligibilityResult as? ORKChoiceQuestionResult {
                                UserDefaults.standard.set(genderResult.choiceAnswers!.first! as! NSString, forKey: SettingsString.participantGender.rawValue)
                            }
                        }
                    }

                    // Show study
                    performSegue(withIdentifier: "unwindToStudy", sender: nil)
                } else {
                    dismiss(animated: true, completion: nil)
                }
            case .discarded, .failed, .saved:
                dismiss(animated: true, completion: nil)
        }
    }
}
