//
//  SearchResult.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 25.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import ResearchKit

class SearchResult: ORKResult {
    var participantIdentifier: String
    var targetItem: SearchItemProtocol
    var layout: LayoutType
    var organisation: OrganisationType
    var itemCount: Int
    var isPractice: Bool
    var itemLocation: IndexPath
    var sameColorCount: Int
    var pressedItem: SearchItemProtocol?
    var pressLocation: IndexPath?
    var searchTime: TimeInterval?
    
    var isError: Bool {
        return itemLocation != pressLocation
    }
    
    init(identifier: String, participantIdentifier: String, targetItem: SearchItemProtocol, itemLocation: IndexPath, layout: LayoutType, organisation: OrganisationType, itemCount: Int, sameColorCount: Int, isPractice: Bool) {
        self.participantIdentifier = participantIdentifier
        self.targetItem = targetItem
        self.layout = layout
        self.organisation = organisation
        self.itemCount = itemCount
        self.itemLocation = itemLocation
        self.sameColorCount = sameColorCount
        self.isPractice = isPractice
        
        super.init(identifier: identifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var description: String {
        return csvRow.joined(separator: ",")
    }
    
    var csvHeadlines: [String] {
        return ["ParticipantId","Trial","Layout","Organisation","ItemCount","SameColorCount","SearchTime","ItemLocationRow","ItemLocationColumn","PressLocationRow","PressLocationColumn","Practice","Error"]
    }
    
    var csvRow: [String] {
        return [participantIdentifier,identifier,layout.description,organisation.description,"\(itemCount)","\(sameColorCount)","\(searchTime ?? -1)","\(itemLocation.row)","\(itemLocation.section)","\(pressLocation?.row ?? -1)","\(pressLocation?.section ?? -1)","\(isPractice)","\(isError)"]
    }
}
