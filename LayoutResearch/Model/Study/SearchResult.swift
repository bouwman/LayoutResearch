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

class SearchResult: ORKResult {
    var participantIdentifier: String
    var targetItem: SearchItemProtocol
    var layout: LayoutType
    var organisation: OrganisationType
    var itemCount: Int
    var isPractice: Bool
    var itemLocation: IndexPath
    var sameColorCount: Int
    var targetFrequency: Int
    var activityNumber: Int
    var pressedItem: SearchItemProtocol?
    var pressLocation: IndexPath?
    var searchTime: TimeInterval?
    var distanceCondition: SearchItemDistance?
    var distanceToNearestSharedColor: Int?
    var closeNeighboursCount: Int?
    var isError: Bool?
    
    init(identifier: String, participantIdentifier: String, targetItem: SearchItemProtocol, itemLocation: IndexPath, layout: LayoutType, organisation: OrganisationType, itemCount: Int, sameColorCount: Int, targetFrequency: Int, isPractice: Bool, activityNumber: Int) {
        self.participantIdentifier = participantIdentifier
        self.targetItem = targetItem
        self.layout = layout
        self.organisation = organisation
        self.itemCount = itemCount
        self.itemLocation = itemLocation
        self.sameColorCount = sameColorCount
        self.targetFrequency = targetFrequency
        self.isPractice = isPractice
        self.activityNumber = activityNumber
        
        super.init(identifier: identifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var description: String {
        return csvRow.joined(separator: ",")
    }
    
    var csvHeadlines: [String] {
        return ["ParticipantId","Attempt","Trial","Layout","Organisation","ItemCount","SameColorCount","DistanceCondition","DistanceToNearestSharedColor","CloseNeighboursCount","TargetFrequency","SearchTime","ItemLocationRow","ItemLocationColumn","PressLocationRow","PressLocationColumn","Practice","Error"]
    }
    
    var csvRow: [String] {
        return [participantIdentifier,"\(activityNumber)",identifier,String(describing: layout),String(describing: organisation),"\(itemCount)","\(sameColorCount)",String(describing: distanceCondition ?? nil),"\(distanceToNearestSharedColor ?? -1)","\(closeNeighboursCount ?? -1)","\(targetFrequency)","\(searchTime ?? -1)","\(itemLocation.row)","\(itemLocation.section)","\(pressLocation?.row ?? -1)","\(pressLocation?.section ?? -1)","\(isPractice)","\(isError ?? true)"]
    }
}
