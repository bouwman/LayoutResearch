//
//  ConsentDocument.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 25.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import ResearchKit

class ConsentDocument: ORKConsentDocument {
    // MARK: Properties
    
    let ipsum = [
        "We would like to invite you to participate in this research project directed by researchers at UCL. You should only participate if you want to; choosing not to take part will not disadvantage you in any way. Before you decide whether you want to take part, it is important for you to read the following information carefully and discuss it with others if you wish. Ask us if there is anything that is not clear or if you would like more information.\n\nTitle of Project: Visual search in circular icon arrangements\n\nThis study has been approved by the UCL Interaction Centre Research Department’s Ethics Chair\nProject ID No: UCLIC/1617/005/MSc Brumby/Schioler",
        "We shall record how long it takes you to select an application icon and whether it is the correct one for that trial. The data is gathered on your phone. With your permission the data is send to another computers to analyse it.",
        "All data will be handled according to the Data Protection Act 1998 and will be kept anonymous.",
        "Only UCL researchers working with Tassilo Bouwman and Duncan Brumby will analyse these data. With your permission, we may want to use this data for teaching, conferences, presentations, publications, and/or thesis work.",
        "You agree to commit about 5 minutes per day over a period of three days. We will ask you to complete the search task once per day.",
        "This study may ask you to fill in surveys about your opinion regarding certain design features.",
        "In this study you will need to find and select a specific application icon on the screen of a computer. We shall record how long it takes you to select an application icon and whether it is the correct one for that trial. Between different trials features of the icons on the interface may change. We are interested in how these design features affect your performance.",
        "It is up to you to decide whether or not to take part. If you decide to take part you will be given this information sheet to keep and be asked to sign a consent form. If you decide to take part you are still free to withdraw at any time and without giving a reason."
    ]
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        title = NSLocalizedString("Informed Consent Form", comment: "")
        
        let sectionTypes: [ORKConsentSectionType] = [
            .overview,
            .dataGathering,
            .privacy,
            .dataUse,
            .timeCommitment,
            .studySurvey,
            .studyTasks,
            .withdrawing
        ]
        sections = []
        
        for sectionType in sectionTypes {
            let section = ORKConsentSection(type: sectionType)
            
            let localizedIpsum = NSLocalizedString(ipsum[sectionTypes.firstIndex(of: sectionType)!], comment: "")
            let localizedSummary = localizedIpsum.components(separatedBy: ".")[0] + "."
            
            section.summary = localizedSummary
            section.content = localizedIpsum
            if sections == nil {
                sections = [section]
            } else {
                sections!.append(section)
            }
        }
        
        let signature = ORKConsentSignature(forPersonWithTitle: "Participant", dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature")
        addSignature(signature)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ORKConsentSectionType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .overview:
            return "Overview"
            
        case .dataGathering:
            return "DataGathering"
            
        case .privacy:
            return "Privacy"
            
        case .dataUse:
            return "DataUse"
            
        case .timeCommitment:
            return "TimeCommitment"
            
        case .studySurvey:
            return "StudySurvey"
            
        case .studyTasks:
            return "StudyTasks"
            
        case .withdrawing:
            return "Withdrawing"
            
        case .custom:
            return "Custom"
            
        case .onlyInDocument:
            return "OnlyInDocument"
        @unknown default:
            fatalError()
        }
    }
}

