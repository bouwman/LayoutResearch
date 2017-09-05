//
//  SearchResult.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 25.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import ResearchKit

enum SearchItemDistance {
    case together, apart, furtherApart, farApart
    
    init(rowDistance: Int) {
        let apartDefinition = Const.StudyParameters.itemDistanceApartCondition
        let furtherApartDefinition = Const.StudyParameters.itemDistanceFurtherApartCondition
        switch rowDistance {
        case _ where rowDistance < apartDefinition:
            self = .together
        case apartDefinition:
            self = .apart
        case furtherApartDefinition:
            self = .furtherApart
        case _ where rowDistance > furtherApartDefinition.upperBound:
            self = .farApart
        default:
            self = .farApart
        }
    }
}

struct StepSettings {
    var activityNumber: Int
    var trialNumber: Int
    var targetItem: SearchItemProtocol
    var targetDescriptionPosition: Int
    var targetTrialNumber: Int
    var layout: LayoutType
    var organisation: OrganisationType
    var participantGroup: ParticipantGroup
    var itemCount: Int
    var itemDiameter: CGFloat
    var itemDistance: CGFloat
    var isPractice: Bool
}

class SearchResult: ORKResult {
    var participantIdentifier: String
    var settings: StepSettings
    var itemLocation: IndexPath
    var sameColorCount: Int
    var targetFrequency: Int
    var targetTrialNumber: Int
    var participantAge: Int
    var participantGender: String
    var screenSize: String
    var language: String
    var hoursSinceLastActivity: Int?
    var pressedItem: SearchItemProtocol?
    var pressLocation: IndexPath?
    var searchTime: TimeInterval?
    var distanceCondition: SearchItemDistance?
    var distanceToNearestSharedColor: Int?
    var closeNeighboursCount: Int?
    var isError: Bool?
    
    init(identifier: String, participantIdentifier: String, settings: StepSettings, itemLocation: IndexPath, sameColorCount: Int, targetFrequency: Int, targetTrialNumber: Int, participantAge: Int, participantGender: String, screenSize: String, language: String) {
        self.settings = settings
        self.participantIdentifier = participantIdentifier
        self.itemLocation = itemLocation
        self.sameColorCount = sameColorCount
        self.targetFrequency = targetFrequency
        self.targetTrialNumber = targetTrialNumber
        self.participantAge = participantAge
        self.screenSize = screenSize
        self.participantGender = participantGender
        self.language = language
        
        super.init(identifier: identifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var description: String {
        return csvRow.joined(separator: ",")
    }
    
    var csvHeadlines: [String] {
        return [
            "Attempt",
            "Trial",
            "Search Time",
            "Layout",
            "Organisation",
            "Target Frequency",
            "Target Description Position",
            "Same Color Count",
            "Distance Condition",
            "Distance To Nearest Shared Color",
            "Close Neighbours Count",
            "Hours since last attempt",
            "Randomness",
            "Target Id",
            "Target Color",
            "Target Shape",
            "Target Trial Number",
            "Item Location Row",
            "Item Location Column",
            "Press Location Row",
            "Press Location Column",
            "Group",
            "Practice",
            "Error",
            "Screen Size",
            "Language",
            "Age",
            "Gender",
            "Total Item Count",
            "Participant Id"
        ]
    }
    
    var csvRow: [String] {
        return [
            "\(settings.activityNumber)",
            identifier,
            "\(searchTime ?? -1)",
            String(describing: settings.layout),
            String(describing: settings.organisation),
            "\(targetFrequency)",
            "\(settings.targetDescriptionPosition)",
            "\(sameColorCount)",
            distanceCondition == nil ? "–" : String(describing: distanceCondition!),
            "\(distanceToNearestSharedColor ?? -1)",
            "\(closeNeighboursCount ?? -1)",
            "\(hoursSinceLastActivity ?? -1)",
            settings.participantGroup.isDesignedLayout ? "Designed layout" : "Random layout",
            "\(settings.targetItem.identifier)",
            "\(settings.targetItem.colorId)",
            "\(settings.targetItem.shapeId)",
            "\(targetTrialNumber)",
            "\(itemLocation.row)",
            "\(itemLocation.section)",
            "\(pressLocation?.row ?? -1)",
            "\(pressLocation?.section ?? -1)",
            String(describing: settings.participantGroup),
            "\(settings.isPractice)",
            "\(isError ?? true)",
            screenSize,
            language,
            "\(participantAge)",
            "\(participantGender)",
            "\(settings.itemCount)",
            participantIdentifier
        ]
    }
}
