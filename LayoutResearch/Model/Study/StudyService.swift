//
//  StudyService.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 25.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import ResearchKit

enum OrganisationType {
    case random, stable
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

class StudyService {
    var steps: [ORKStep] = []
    var activityNumber: Int
    var settings: StudySettings
    
    private var searchItems: [[SearchItemProtocol]] = []
    private var targetItems: [SearchItemProtocol] = []
    
    init(settings: StudySettings, activityNumber: Int) {
        self.settings = settings
        self.activityNumber = activityNumber
        
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
        targetItems = settings.group.targetItemsFrom(searchItems: searchItems)
        
        // Create intro step
        let introStep = ORKInstructionStep(identifier: "IntroStep")
        introStep.title = "Introduction"
        introStep.text = "Please read this carefully.\n\nTry to find an icon as quickly as possible.\n\nAt the start of each trial, you are told which icon you are looking for.\n\nYou start a trial by clicking on the 'Next' button shown under the description. The 'Next' button will appear after 1 second. On pressing the button, the icon image will disappear, and the menu appears.\nTry to locate the item as quickly as possible and click on it.\n\nAs soon as you select the correct item you are taken to the next trial. If you selected the wrong trial, the description of the item will be shown again."
        steps.append(introStep)
        
        // Create practice intro step
        let practiceIntroStep = ORKActiveStep(identifier: "PracticeIntroStep")
        practiceIntroStep.title = "Practice"
        practiceIntroStep.text = "Use the next few trials to become familiar with the search task. Press next to begin."
        steps.append(practiceIntroStep)
        
        // Create practice steps
        var trialCounter = 0
        let layouts = settings.group.layouts
        let practiceTargets = settings.group.practiceTargetItemsFrom(searchItems: searchItems)
        for i in 0..<settings.practiceTrialCount {
            addTrialStepsFor(index: trialCounter, layout: layouts.first!, target: practiceTargets[i], isPractice: true)
            trialCounter += 1
        }
        
        // Create experiment start step
        let normalIntroStep = ORKActiveStep(identifier: "NormalIntroStep")
        normalIntroStep.title = "Start of Experiment"
        normalIntroStep.text = "You have completed the practice trials. Press next to begin the experiment."
        steps.append(normalIntroStep)
        
        // Create normal steps
        for (i, layout) in layouts.enumerated() {
            // Not add layout intro after intro
            if i != 0 {
                // Take a break
//                let waitStep = ORKCountdownStep(identifier: "CountdownStep\(layouts.count + i)")
//                waitStep.title = "Break"
//                waitStep.text = "Take a short break before you continue."
//                waitStep.stepDuration = 15
//                waitStep.shouldStartTimerAutomatically = true
//                waitStep.shouldShowDefaultTimer = true
//                steps.append(waitStep)
                
                // Introduce new layout
                let newLayoutStep = LayoutIntroStep(identifier: "NewLayoutStep\(layouts.count + i)", items: layoutIntroItems, layout: layout, itemDiameter: settings.itemDiameter, itemDistance: settings.itemDistanceWithEqualWhiteSpaceFor(layout: layout))
                newLayoutStep.title = "New Layout"
                newLayoutStep.text = "The next layout will be different but the task is the same: Locate the target as quickly as possible."
                steps.append(newLayoutStep)
            }
            
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
            swap(&array[i], &array[half + i])
            // TODO: Xcode 9
//            array.swapAt(i, half + i)
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
        
        var apartItemsUpOnSameColumn = true
        var apartItemsDownOnSameColumn = true
        repeat {
            let apartId = Const.StudyParameters.colorIdApartCondition
            
            let itemIndexRow1 = array[0].index(where: { $0.colorId == apartId })
            let itemIndexRow2 = array[1].index(where: { $0.colorId == apartId })
            let itemIndexRow3 = array[2].index(where: { $0.colorId == apartId })

            let itemIndexRowLast3 = array[array.count - 3].index(where: { $0.colorId == apartId })
            let itemIndexRowLast2 = array[array.count - 2].index(where: { $0.colorId == apartId })
            let itemIndexRowLast1 = array[array.count - 1].index(where: { $0.colorId == apartId })
            
            if itemIndexRow2 == itemIndexRow1 || itemIndexRow2 == itemIndexRow3 {
                array[1].shuffle()
                apartItemsUpOnSameColumn = true
            } else {
                apartItemsUpOnSameColumn = false
            }
            if itemIndexRowLast2 == itemIndexRowLast3 || itemIndexRowLast2 == itemIndexRowLast1 {
                array[array.count - 2].shuffle()
                apartItemsDownOnSameColumn = true
            } else {
                apartItemsDownOnSameColumn = false
            }
        } while (apartItemsUpOnSameColumn || apartItemsDownOnSameColumn)
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
        let searchStep = SearchStep(identifier: searchStepIdentifier, participantIdentifier: settings.participant, items: searchItems, targetItem: target, targetFrequency: countFrequencyOf(target: target), layout: layout, organisation: settings.group.organisation, itemDiameter: settings.itemDiameter, itemDistance: settings.itemDistanceWithEqualWhiteSpaceFor(layout: layout), isPractice: isPractice, activityNumber: activityNumber)
        
        descriptionStep.title = "Search"
        descriptionStep.text = "Find this item as quickly as possible."
        
        steps.append(descriptionStep)
        steps.append(searchStep)
    }
    
    var isColorFarApartCondition1LastFarApart = false
    var isColorFarApartCondition2LastFarApart = false
    
    private func countFrequencyOf(target: SearchItemProtocol) -> Int {
        return (targetItems.filter { $0.colorId == target.colorId && $0.shapeId == target.shapeId }).count * settings.group.layouts.count
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
    
    private func otherColorDistractorCountLowId(colorId: Int) -> Int {
        if colorId == Const.StudyParameters.colorIdFarApartCondition1 {
            return Const.StudyParameters.colorIdFarApartCondition2
        } else {
            return Const.StudyParameters.colorIdFarApartCondition1
        }
    }
    
    private var staticColors: [[Int]] {
        var colors: [[Int]] = []
        let c = Const.StudyParameters.colorIdFarApartCondition1 // 5
        let d = Const.StudyParameters.colorIdFarApartCondition2 // 6
        let a = Const.StudyParameters.colorIdApartCondition // 2
        
        let colorRow1 = [1, 1, c, a, 0, 0, 0, 0, 0, 0]
        let colorRow2 = [1, a, 3, 1, 0, 0, 0, 0, 0, 0]
        let colorRow3 = [a, 1, d, 1, 0, 0, 0, 0, 0, 0]
        let colorRow4 = [4, a, d, 4, 0, 0, 0, 0, 0, 0]
        let colorRow5 = [4, 3, 4, a, 0, 0, 0, 0, 0, 0]
        let colorRow6 = [a, c, 4, 4, 0, 0, 0, 0, 0, 0]
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
