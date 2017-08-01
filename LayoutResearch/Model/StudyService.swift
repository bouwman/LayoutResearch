//
//  StudyService.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 25.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import ResearchKit

enum OrganisationType: CustomStringConvertible {
    case random, stable
    
    var description: String {
        switch self {
        case .random:
            return "Random"
        case .stable:
            return "Stable"
        }
    }
}

class StudyService {
    var steps: [ORKStep] = []
    var settings: StudySettings
    
    private var searchItems: [[SearchItemProtocol]] = []
    private var targetItems: [SearchItemProtocol] = []
    
    init(settings: StudySettings) {
        self.settings = settings
        
        // Create base item array
        var counter = 1
        for row in 0..<settings.rowCount {
            var rowItems: [SearchItemProtocol] = []
            for column in 0..<settings.columnCount {
                let colorId = staticColors[row][column]
                let sharedColorCount = countColorsIn(colorArray: staticColors, colorId: colorId)
                let item = SearchItem(identifier: "\(counter)", colorId: colorId, shapeId: counter, sharedColorCount: sharedColorCount)
                rowItems.append(item)
                targetItems.append(item)
                
                // Counters
                counter += 1
            }
            searchItems.append(rowItems)
        }
        
        // Create targets
        targetItems = pickStaticTargetItems()
        
        // Shuffle items at least once
        shuffle2dArrayMaintainingColorDistance(&searchItems)
        targetItems.shuffle()
        
        // Create intro step
        let introStep = ORKInstructionStep(identifier: "IntroStep")
        introStep.title = "Introduction"
        introStep.text = "Try to find an icon as quickly as possible.\n\nAt the start of each trial, you are told which icon you are looking for.\n\nYou start a trial by clicking on the 'Next' button shown under the description. On pressing the button, the icon image will disappear, and the menu appears.\nTry to locate the item as quickly as possible and click on it.\n\nAs soon as you select an item you are taken to the next trial. There is no chance to repeat the trial."
        steps.append(introStep)
        
        // Create practice intro step
        let practiceIntroStep = ORKActiveStep(identifier: "PracticeIntroStep")
        practiceIntroStep.title = "Practice"
        practiceIntroStep.text = "Use the next few trials to become familiar with the search task."
        steps.append(practiceIntroStep)
        
        // Create practice steps
        var trialCounter = 0
        let layouts = settings.group.layouts
        for i in 0..<settings.practiceTrialCount {
            addTrialStepsFor(index: trialCounter, layout: layouts.first!, target: targetItems[targetItems.count - i - 1], isPractice: true)
            trialCounter += 1
        }
        
        // Create experiment start step
        let normalIntroStep = ORKActiveStep(identifier: "NormalIntroStep")
        normalIntroStep.title = "Start of Experiment"
        normalIntroStep.text = "Start the experiment by pressing the next button"
        steps.append(normalIntroStep)
        
        // Create normal steps
        for (i, layout) in layouts.enumerated() {
            // Not add layout intro after intro
            if i != 0 {
                let newLayoutStep = LayoutIntroStep(identifier: "NewLayoutStep\(layouts.count + i)", items: layoutIntroItems, layout: layout, itemDiameter: settings.itemDiameter, itemDistance: settings.itemDistanceWithEqualWhiteSpaceFor(layout: layout))
                newLayoutStep.title = "New Layout"
                newLayoutStep.text = "The next layout will be different"
                steps.append(newLayoutStep)
            }
            // Different target order for every layout
            targetItems.shuffle()
            
            // Create steps for every target
            for i in 0..<targetItems.count {
                addTrialStepsFor(index: trialCounter, layout: layout, target: targetItems[i], isPractice: false)
                trialCounter += 1
            }
        }
        
        // Add thank you step
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = "Thank you!"
        completionStep.text = "Thank you for completing the task."
        steps.append(completionStep)
    }
    
    private func shuffle2dArrayMaintainingColorDistance(_ array: inout [[SearchItemProtocol]]) {
        // Rows must be even
        guard array.count % 2 == 0 else { return }
        let half = array.count / 2
        
        // Swap first half with second half
        for i in 0..<half {
            array.swapAt(i, half + i)
        }
        // Shuffle all rows
        for (row, rowItems) in array.enumerated() {
            let shuffledRow = rowItems.shuffled()
            array[row] = shuffledRow
        }
        
        var middleRowItemsGrouped = false
        
        repeat {
            let middleUpperRow = array[half - 1]
            let middleLowerRow = array[half]
            
            // Make sure two items are grouped in the middle
            let upperItemColumn = middleUpperRow.index(where: { $0.sharedColorCount == settings.distractorColorLowCount })
            let lowerItemColumn = middleLowerRow.index(where: { $0.sharedColorCount == settings.distractorColorLowCount })
            
            // Stop if on top of each other
            if  upperItemColumn == lowerItemColumn {
                middleRowItemsGrouped = true
            } else { // Shuffle a
                array[half - 1] = middleUpperRow.shuffled()
                array[half] = middleLowerRow.shuffled()
            }
        } while (middleRowItemsGrouped == false)
    }
    
    private func shuffle2dArray(_ array: inout [[SearchItemProtocol]]) {
        let flatMap = array.flatMap { $0 }
        let itemsShuffled = flatMap.shuffled()
        var itemCounter = 0
        for (row, rowItems) in array.enumerated() {
            for (column, _) in rowItems.enumerated() {
                array[row][column] = itemsShuffled[itemCounter]
                itemCounter += 1
            }
        }
    }

    private func addTrialStepsFor(index: Int, layout: LayoutType, target: SearchItemProtocol, isPractice: Bool) {
        // Shuffle layout for every trial if random
        if settings.group.organisation == .random {
            shuffle2dArrayMaintainingColorDistance(&searchItems)
            
            // Shuffle again if target has not the distance it should have
            shuffleSearchItemsIfNeededFor(target: target)
        }
        
        let searchStepIdentifier = "\(index)"
        let descriptionStep = SearchDescriptionStep(identifier: "SearchDescription\(searchStepIdentifier)", targetItem: target, targetDiameter: settings.itemDiameter)
        let searchStep = SearchStep(identifier: searchStepIdentifier, participantIdentifier: settings.participant, items: searchItems, targetItem: target, targetFrequency: countFrequencyOf(target: target), layout: layout, organisation: settings.group.organisation, itemDiameter: settings.itemDiameter, itemDistance: settings.itemDistanceWithEqualWhiteSpaceFor(layout: layout), isPractice: isPractice)
        
        descriptionStep.title = "Search"
        descriptionStep.text = "Find this item in the next layout as quickly as possible"
        
        steps.append(descriptionStep)
        steps.append(searchStep)
    }
    
    var isColorFarApartCondition1LastFarApart = false
    var isColorFarApartCondition2LastFarApart = false
    
    private func countFrequencyOf(target: SearchItemProtocol) -> Int {
        return (targetItems.filter { $0.colorId == target.colorId && $0.shapeId == target.shapeId }).count
    }
    
    private func shuffleSearchItemsIfNeededFor(target: SearchItemProtocol) {
        if target.sharedColorCount == settings.distractorColorLowCount {
            for (row, rowItems) in searchItems.enumerated() {
                for item in rowItems {
                    // Found the target item
                    if item.colorId == target.colorId {
                        let isFarApart = row == 0
                        let isGrouped = row == (searchItems.count / 2 - 1)
                        let isColorCondition1 = target.colorId == Const.StudyParameters.colorIdFarApartCondition1
                        let isColorCondition2 = target.colorId == Const.StudyParameters.colorIdFarApartCondition2
                        
                        if isColorCondition1 {
                            if isGrouped && isColorFarApartCondition1LastFarApart {
                                isColorFarApartCondition1LastFarApart = false
                            } else if isGrouped && !isColorFarApartCondition1LastFarApart  {
                                isColorFarApartCondition1LastFarApart = true
                                shuffle2dArrayMaintainingColorDistance(&searchItems)
                            } else if isFarApart && isColorFarApartCondition1LastFarApart {
                                isColorFarApartCondition1LastFarApart = false
                                shuffle2dArrayMaintainingColorDistance(&searchItems)
                            } else if isFarApart && !isColorFarApartCondition1LastFarApart {
                                isColorFarApartCondition1LastFarApart = true
                            }
                        } else if isColorCondition2 {
                            if isGrouped && isColorFarApartCondition2LastFarApart {
                                isColorFarApartCondition2LastFarApart = false
                            } else if isGrouped && !isColorFarApartCondition2LastFarApart  {
                                isColorFarApartCondition2LastFarApart = true
                                shuffle2dArrayMaintainingColorDistance(&searchItems)
                            } else if isFarApart && isColorFarApartCondition2LastFarApart {
                                isColorFarApartCondition2LastFarApart = false
                                shuffle2dArrayMaintainingColorDistance(&searchItems)
                            } else if isFarApart && !isColorFarApartCondition2LastFarApart {
                                isColorFarApartCondition2LastFarApart = true
                            }
                        }
                        break
                    }
                }
            }
        }
    }
    
    private func pickStaticTargetItems() -> [SearchItemProtocol] {
        var items: [SearchItemProtocol] = []
        
        // Color distractor count high
        let colorDistractorCountHighFrequencyHighDistanceClose = searchItems[0][0] // Blue
        let colorDistractorCountHighFrequencyLowDistanceClose = searchItems[1][0] // Blue
        let colorDistractorCountHighFrequencyHighDistanceApart = searchItems[2][0] // Orange
        let colorDistractorCountHighFrequencyLowDistanceApart = searchItems[5][0] // Orange
        
        // Color distractor count low
        let colorDistractorCountLowFrequencyHighDistanceClose = searchItems[2][3] // Dark green
        let colorDistractorCountLowFrequencyLowDistanceClose = searchItems[3][3] // Dark green
        let colorDistractorCountLowFrequencyHighDistanceApart = searchItems[1][2] // Dark blue
        let colorDistractorCountLowFrequencyLowDistanceApart = searchItems[4][1] // Dark blue
        let colorDistractorCountLowFrequencyHighDistanceFarApart = searchItems[0][1] // Green
        let colorDistractorCountLowFrequencyLowDistanceFarApart = searchItems[5][2] // Green

        // Add items according to their frequency
        appendItemToArray(&items, times: settings.targetFreqHighCount, item: colorDistractorCountHighFrequencyHighDistanceClose)
        appendItemToArray(&items, times: settings.targetFreqLowCount, item: colorDistractorCountHighFrequencyLowDistanceClose)
        appendItemToArray(&items, times: settings.targetFreqHighCount, item: colorDistractorCountHighFrequencyHighDistanceApart)
        appendItemToArray(&items, times: settings.targetFreqLowCount, item: colorDistractorCountHighFrequencyLowDistanceApart)
        appendItemToArray(&items, times: settings.targetFreqHighCount, item: colorDistractorCountLowFrequencyHighDistanceClose)
        appendItemToArray(&items, times: settings.targetFreqLowCount, item: colorDistractorCountLowFrequencyLowDistanceClose)
        appendItemToArray(&items, times: settings.targetFreqHighCount, item: colorDistractorCountLowFrequencyHighDistanceApart)
        appendItemToArray(&items, times: settings.targetFreqLowCount, item: colorDistractorCountLowFrequencyLowDistanceApart)
        appendItemToArray(&items, times: settings.targetFreqHighCount, item: colorDistractorCountLowFrequencyHighDistanceFarApart)
        appendItemToArray(&items, times: settings.targetFreqLowCount, item: colorDistractorCountLowFrequencyLowDistanceFarApart)

        return items
    }
    
    private func appendItemToArray(_ array: inout [SearchItemProtocol], times: Int, item: SearchItemProtocol) {
        for _ in 0..<times {
            array.append(item)
        }
    }
    
    private func otherColorDistractorCountLowId(colorId: Int) -> Int {
        if colorId == Const.StudyParameters.colorIdFarApartCondition1 {
            return Const.StudyParameters.colorIdFarApartCondition2
        } else {
            return Const.StudyParameters.colorIdFarApartCondition1
        }
    }
    
    private var staticColors: [[Int]] {
        var colors: [[Int]] = []
        let c = Const.StudyParameters.colorIdFarApartCondition1
        let d = Const.StudyParameters.colorIdFarApartCondition2
        
        let colorRow1 = [1, c, 1, 2, 0, 0, 0, 0, 0, 0]
        let colorRow2 = [1, 2, 3, 1, 0, 0, 0, 0, 0, 0]
        let colorRow3 = [2, 1, 1, d, 0, 0, 0, 0, 0, 0]
        let colorRow4 = [4, 2, 4, d, 0, 0, 0, 0, 0, 0]
        let colorRow5 = [4, 3, 2, 4, 0, 0, 0, 0, 0, 0]
        let colorRow6 = [2, 4, c, 4, 0, 0, 0, 0, 0, 0]
        let colorRow7 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        let colorRow8 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        let colorRow9 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        let colorRow10 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

        colors.append(colorRow1)
        colors.append(colorRow2)
        colors.append(colorRow3)
        colors.append(colorRow4)
        colors.append(colorRow5)
        colors.append(colorRow6)
        colors.append(colorRow7)
        colors.append(colorRow8)
        colors.append(colorRow9)
        colors.append(colorRow10)

        return colors
    }
    
    private func countColorsIn(colorArray: [[Int]], colorId: Int) -> Int {
        var counter = 0
        for itemRow in colorArray {
            for item in itemRow {
                if item == colorId {
                    counter += 1
                }
            }
        }
        return counter
    }
    
    private var layoutIntroItems: [[SearchItemProtocol]] {
        var items: [[SearchItemProtocol]] = []
        
        var counter = 1
        for _ in 0..<settings.rowCount {
            var rowItems: [SearchItemProtocol] = []
            for _ in 0..<settings.columnCount {
                // 0 for black color and no shape
                let item = SearchItem(identifier: "\(counter)", colorId: 0, shapeId: 0, sharedColorCount: 0)
                rowItems.append(item)
                counter += 1
            }
            items.append(rowItems)
        }
        return items
    }
}
