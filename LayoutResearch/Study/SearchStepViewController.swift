//
//  SearchStepViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 23.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import ResearchKit

protocol SearchStepViewControllerDelegate {
    func didFinishWith(result: SearchResult)
}

class SearchStepViewController: ORKActiveStepViewController {
    var startTime: Date?
    var searchResult: SearchResult?
    
    var searchStep: SearchStep? {
        return step as? SearchStep
    }
    
    static var isSearchedBefore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let searchStep = searchStep else { return }
        
        var topMargin = Const.Interface.searchLayoutMargin
        if searchStep.layout == .vertical && topMargin >= searchStep.itemDistance {
            topMargin -= searchStep.itemDistance
        } else if searchStep.layout == .horizontal {
            topMargin += searchStep.itemDistance
        }
        
        // Create view
        let searchView = SearchView(itemDiameter: searchStep.itemDiameter, distance: searchStep.itemDistance, layout: searchStep.layout, topMargin: topMargin, items: searchStep.items)
        
        searchView.delegate = self
        
        customView = searchView
        
        // Hide next button
        for subview in self.view.subviews {
            for subview1 in subview.subviews {
                for subview2 in subview1.subviews {
                    for subview3 in subview2.subviews {
                        if let button = subview3 as? UIButton {
                            button.isHidden = true
                        }
                    }
                }
            }
        }
                
        // Setup result
        let index = indexOf(searchedItem: searchStep.targetItem, inItems: searchStep.items)
        searchResult = SearchResult(identifier: searchStep.identifier, participantIdentifier: searchStep.participantIdentifier, targetItem: searchStep.targetItem, itemLocation: index!, layout: searchStep.layout, organisation: searchStep.organisation, itemCount: searchStep.itemCount, sameColorCount: searchStep.sameColorCount, isPractice: searchStep.isPractice)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startTime = Date()
    }
    
    private func indexOf(searchedItem: SearchItemProtocol, inItems items: [[SearchItemProtocol]]) -> IndexPath? {
        var index: IndexPath?
        
        for (row, itemsInRow) in items.enumerated() {
            if let column = itemsInRow.index(where: { $0.identifier == searchedItem.identifier }) {
                index = IndexPath(row: row, section: column)
            }
        }
        return index
    }
    
    override var result: ORKStepResult? {
        let sResult = super.result
        
        guard let searchResult = searchResult else { return sResult }
        guard let sResults = sResult?.results else { return sResult }
        
        var results = Array(sResults)
        
        results.append(searchResult)
        
        sResult?.results = results
        
        return sResult
    }
    
    override func start() {
        super.start()
    }
    
    override func resume() {
        super.resume()
    }
}

// MARK: - SearchViewDelegate

extension SearchStepViewController: SearchViewDelegate {
    func didSelect(item: SearchItemProtocol?, atIndex index: IndexPath?) {
        guard let searchResult = searchResult else { return }
        
        searchResult.pressLocation = index
        searchResult.pressedItem = item
        searchResult.isError = searchResult.itemLocation != searchResult.pressLocation
        
        if let startTime = startTime {
            searchResult.searchTime = Date().timeIntervalSince(startTime)
        }
        
        // Go back when error
        if searchResult.isError! {
            SearchStepViewController.isSearchedBefore = true
            delegate?.stepViewController(self, didFinishWith: .reverse)
        } else {
            // When searched before store step as an error
            searchResult.isError = SearchStepViewController.isSearchedBefore
            SearchStepViewController.isSearchedBefore = false
            
            delegate?.stepViewController(self, didFinishWith: .forward)
        }
    }
}

struct SearchItem: SearchItemProtocol, CustomStringConvertible {
    var identifier: String
    var colorId: Int
    var shapeId: Int
    var sharedColorCount: Int
    
    var description: String {
        return identifier
    }
}
