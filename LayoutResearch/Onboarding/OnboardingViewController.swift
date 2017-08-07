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
        let choiceAnswer = ORKBooleanAnswerFormat(yesString: "YES", noString: "NO")
        let ageItem = ORKFormItem(identifier: "eligibilityItemAge", text: "Are you 18 or older?", answerFormat: choiceAnswer)
        let englishItem = ORKFormItem(identifier: "eligibilityItemEnglish", text: "Are you comfortable with reading and writing on this device in English?", answerFormat: choiceAnswer)
        
        ageItem.isOptional = false
        englishItem.isOptional = false
        
        let eligibilityStep = ORKFormStep(identifier: "EligibilityStep")
        eligibilityStep.formItems = [ageItem, englishItem]
        eligibilityStep.isOptional = false
        
        let consentStep = ORKVisualConsentStep(identifier: Const.Identifiers.visualConsentStep, document: consentDocument)
        let signature = consentDocument.signatures!.first!
        let reviewConsentStep = ORKConsentReviewStep(identifier: Const.Identifiers.consetReviewStep, signature: signature, in: consentDocument)
        
        reviewConsentStep.text = "Review the consent form."
        reviewConsentStep.reasonForConsent = "Consent to join the Visual search in circular icon arrangements study."
        
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = "Welcome aboard."
        completionStep.text = "Thank you for joining this study."
        
        let notEligibleStep = ORKCompletionStep(identifier: "NotEligibleStep")
        notEligibleStep.title = "Sorry"
        notEligibleStep.text = "Thank you for your interest in our study. Unfortunately you are not eligible to take part in this study."
        
        let ageSelector = ORKResultSelector(stepIdentifier: eligibilityStep.identifier, resultIdentifier: ageItem.identifier)
        let englishSelector = ORKResultSelector(stepIdentifier: eligibilityStep.identifier, resultIdentifier: englishItem.identifier)
        let agePredicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: ageSelector, expectedAnswer: true)
        let englishPredicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: englishSelector, expectedAnswer: true)
        let eligibilityRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [(agePredicate, reviewConsentStep.identifier), (englishPredicate, reviewConsentStep.identifier)], defaultStepIdentifierOrNil: notEligibleStep.identifier)
        let endAfterNotEligibleRule = ORKDirectStepNavigationRule(destinationStepIdentifier: "")
        
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
                if let stepResult = result.stepResult(forStepIdentifier: Const.Identifiers.consetReviewStep),
                    let signatureResult = stepResult.results?.first as? ORKConsentSignatureResult {
                    signatureResult.apply(to: consentDocument)
                    
                    // Save pdf
                    consentDocument.makePDF(completionHandler: { (data, error) in
                        self.fileService.saveConsent(data: data)
                    })
                    
                    // Save name
                    UserDefaults.standard.set(signatureResult.signature?.familyName, forKey: SettingsString.participantFamilyName.rawValue)
                    UserDefaults.standard.set(signatureResult.signature?.givenName, forKey: SettingsString.participantGivenName.rawValue)

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
