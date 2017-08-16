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
        searchView.alpha = 0.0
        
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
        
        // Load age
        let age = UserDefaults.standard.integer(forKey: SettingsString.participantAge.rawValue)
        let gender = UserDefaults.standard.string(forKey: SettingsString.participantGender.rawValue) ?? "–"
        let groupStringOptional = UserDefaults.standard.string(forKey: SettingsString.participantGroup.rawValue)
        guard let groupString = groupStringOptional, let group = ParticipantGroup(rawValue: groupString) else { return }
        
        // Determine screen size
        let screenSize = UIScreen.main.bounds
        let screenSizeString = "\(screenSize.width)x\(screenSize.height)"
        
        // Setup result
        let index = indexOf(searchedItem: searchStep.targetItem, inItems: searchStep.items)
        searchResult = SearchResult(identifier: searchStep.identifier, participantIdentifier: searchStep.participantIdentifier, targetItem: searchStep.targetItem, itemLocation: index!, layout: searchStep.layout, organisation: searchStep.organisation, participantGroup: group, itemCount: searchStep.itemCount, sameColorCount: searchStep.sameColorCount, targetFrequency: searchStep.targetFrequency, isPractice: searchStep.isPractice, activityNumber: searchStep.activityNumber, participantAge: age, participantGender: gender, screenSize: screenSizeString)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startTime = Date()
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
            self.customView?.alpha = 1.0
        }, completion: nil)
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
    
    static func calcDistanceToNearestSharedColorIn(searchItems: [[SearchItemProtocol]], targetItem: SearchItemProtocol, layout: LayoutType = .grid) -> (distance: Int?, shortestRowDistance: Int?, shortestColumnDistance: Int?, closestNeighboursCount: Int?) {
        guard searchItems.count != 0 else { return (nil, nil, nil, nil) }
        var targetItemPositionOptional: IndexPath?
        var otherItemsPositions: [IndexPath] = []
        
        // Find position of all items with same color
        for (row, itemRow) in searchItems.enumerated() {
            for (column, item) in itemRow.enumerated() {
                if item.colorId == targetItem.colorId {
                    if item.shapeId == targetItem.shapeId {
                        targetItemPositionOptional = IndexPath(row: row, section: column)
                    } else {
                        otherItemsPositions.append(IndexPath(row: row, section: column))
                    }
                }
            }
        }
        // Return when not at least two items found
        guard let targetItemPosition = targetItemPositionOptional, otherItemsPositions.count != 0 else { return (nil, nil, nil, nil) }
        
        // Find item with shortest distance
        var shortestDistance = searchItems.count + searchItems.first!.count
        var shortestRowDistance = searchItems.count + 1
        var shortestColumnDistance = searchItems.first!.count + 1
        var closeNeighboursCount = 0
        for itemPosition in otherItemsPositions {
            let difference = targetItemPosition - itemPosition
            let distance = abs(difference.row) + abs(difference.section)
            let rowDistance = abs(difference.row)
            let columnDistance = abs(difference.section)

            if distance < shortestDistance {
                shortestDistance = distance
            }
            if rowDistance < shortestRowDistance {
                shortestRowDistance = rowDistance
            }
            if columnDistance < shortestColumnDistance {
                shortestColumnDistance = columnDistance
            }
            
            // Find all sourrounding items
            let isSameRowOrColum = itemPosition.row == targetItemPosition.row || itemPosition.section == targetItemPosition.section
            if distance == 1 && isSameRowOrColum {
                closeNeighboursCount += 1
            } else if distance == 1 || distance == 2 {
                let downLeft = IndexPath(row: targetItemPosition.row + 1, section: targetItemPosition.section - 1)
                let downRight = IndexPath(row: targetItemPosition.row + 1, section: targetItemPosition.section + 1)
                let upLeft = IndexPath(row: targetItemPosition.row - 1, section: targetItemPosition.section - 1)
                let upRight = IndexPath(row: targetItemPosition.row - 1, section: targetItemPosition.section + 1)
                switch layout {
                case .horizontal:
                    if targetItemPosition.row % 2 == 0 { // even row
                        if itemPosition == downRight || itemPosition == upRight {
                            closeNeighboursCount += 1
                        }
                    } else { // uneven row
                        if itemPosition == downLeft || itemPosition == upLeft {
                            closeNeighboursCount += 1
                        }
                    }
                case .vertical:
                    if targetItemPosition.section % 2 == 0 { // even column
                        if itemPosition == downLeft || itemPosition == downRight {
                            closeNeighboursCount += 1
                        }
                    } else { // uneven column
                        if itemPosition == upLeft || itemPosition == upRight {
                            closeNeighboursCount += 1
                        }
                    }
                case .grid:
                    let left = IndexPath(row: targetItemPosition.row, section: targetItemPosition.section - 1)
                    let right = IndexPath(row: targetItemPosition.row, section: targetItemPosition.section + 1)
                    let up = IndexPath(row: targetItemPosition.row - 1, section: targetItemPosition.section)
                    let down = IndexPath(row: targetItemPosition.row - 1, section: targetItemPosition.section)
                    
                    if itemPosition == upLeft {
                        if (otherItemsPositions.filter { $0 == up || $0 == left }).count == 1 {
                            closeNeighboursCount += 1
                        }
                    } else if itemPosition == upRight {
                        if (otherItemsPositions.filter { $0 == up || $0 == right }).count == 1 {
                            closeNeighboursCount += 1
                        }
                    } else if itemPosition == downLeft {
                        if (otherItemsPositions.filter { $0 == down || $0 == left }).count == 1 {
                            closeNeighboursCount += 1
                        }
                    } else if itemPosition == downRight {
                        if (otherItemsPositions.filter { $0 == down || $0 == right }).count == 1 {
                            closeNeighboursCount += 1
                        }
                    }
                }
            }
        }
        
        let rowDistance: Int? = shortestRowDistance <= searchItems.count ? shortestRowDistance : nil
        let columnDistance: Int? = shortestColumnDistance <= searchItems.first!.count ? shortestColumnDistance : nil
        
        return (shortestDistance, rowDistance , columnDistance, closeNeighboursCount)
    }
}

// MARK: - SearchViewDelegate

extension SearchStepViewController: SearchViewDelegate {
    func didSelect(item: SearchItemProtocol?, atIndex index: IndexPath?) {
        guard let searchResult = searchResult else { return }
        guard let searchStep = searchStep else { return }
        
        let sameColors = SearchStepViewController.calcDistanceToNearestSharedColorIn(searchItems: searchStep.items, targetItem: searchStep.targetItem, layout: searchStep.layout)
        
        searchResult.pressLocation = index
        searchResult.pressedItem = item
        searchResult.isError = searchResult.itemLocation != searchResult.pressLocation
        searchResult.distanceToNearestSharedColor = sameColors.distance
        searchResult.closeNeighboursCount = sameColors.closestNeighboursCount
        
        if let shortestRowDistance = sameColors.shortestRowDistance {
            searchResult.distanceCondition = SearchItemDistance(rowDistance: shortestRowDistance)
        }
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
