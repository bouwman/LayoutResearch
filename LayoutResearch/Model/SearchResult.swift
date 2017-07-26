//
//  SearchResult.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 25.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import ResearchKit

class SearchResult: ORKResult {
    
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
    
    init(identifier: String, targetItem: SearchItemProtocol, itemLocation: IndexPath, layout: LayoutType, organisation: OrganisationType, itemCount: Int, sameColorCount: Int, isPractice: Bool) {
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
        return ["Identifier","Layout","Organisation","ItemCount","SameColorCount","ItemLocationRow","ItemLocationColumn","Practice","Error"]
    }
    
    var csvRow: [String] {
        return [identifier,layout.description,organisation.description,"\(itemCount)","\(sameColorCount)","\(itemLocation.row)","\(itemLocation.section)","\(isPractice)","\(isError)"]
    }
}
