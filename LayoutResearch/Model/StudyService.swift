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
                let item = SearchItem(identifier: "\(counter)", colorId: colors[row][column], shapeId: counter)
                rowItems.append(item)
                targetItems.append(item)
                counter += 1
            }
            searchItems.append(rowItems)
        }
        
        // Shuffle target items
        targetItems.shuffle()
        
        // Create enough target items for every trial
        let layouts = settings.group.layouts
        let totalTrials = settings.trialCount * layouts.count + settings.practiceTrialCount * layouts.count
        let targetItemsCopy = targetItems
        while targetItems.count < totalTrials {
            targetItems = targetItems + targetItemsCopy
        }
                
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
        
        for _ in 0..<settings.practiceTrialCount {
            addTrialStepsFor(index: trialCounter, layout: settings.group.layouts.first!, isPractice: true)
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
                let newLayoutStep = LayoutIntroStep(identifier: "NewLayoutStep\(layouts.count + i)", items: layoutIntroItems, layout: layout, itemDiameter: settings.itemDiameter, itemDistance: settings.itemDistance)
                newLayoutStep.title = "New Layout"
                newLayoutStep.text = "The next layout will be different"
                steps.append(newLayoutStep)
            }
            for _ in 0..<settings.trialCount {
                addTrialStepsFor(index: trialCounter, layout: layout, isPractice: false)
                trialCounter += 1
            }
        }
    }
    
    private func addTrialStepsFor(index: Int, layout: LayoutType, isPractice: Bool) {
        // Shuffle layout for every trial if random
        if settings.group.organisation == .random {
            searchItems.shuffle()
            for (i, rowItems) in searchItems.enumerated() {
                searchItems[i] = rowItems.shuffled()
            }
        }
        
        let targetItem = targetItems[index]
        let searchStepIdentifier = "\(isPractice ? "(Practice)" : "")Trial\(index)"
        let descriptionStep = SearchDescriptionStep(identifier: "SearchDescription\(searchStepIdentifier)", targetItem: targetItem, targetDiameter: settings.itemDiameter)
        let searchStep = SearchStep(identifier: searchStepIdentifier, participantIdentifier: settings.participant, items: searchItems, targetItem: targetItem, layout: layout, organisation: settings.group.organisation, itemDiameter: settings.itemDiameter, itemDistance: settings.itemDistance, isPractice: isPractice)
        
        descriptionStep.title = "Search"
        descriptionStep.text = "Find this item in the next layout as quickly as possible"
        
        steps.append(descriptionStep)
        steps.append(searchStep)
    }
    
    private var colors: [[Int]] {
        var colors: [[Int]] = []
        
        let colorRow1 = [1, 3, 2, 1, 4, 0, 0, 0, 0, 0]
        let colorRow2 = [4, 6, 2, 4, 3, 0, 0, 0, 0, 0]
        let colorRow3 = [5, 2, 1, 5, 2, 0, 0, 0, 0, 0]
        let colorRow4 = [1, 7, 6, 1, 4, 0, 0, 0, 0, 0]
        let colorRow5 = [5, 3, 2, 1, 3, 0, 0, 0, 0, 0]
        let colorRow6 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
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
    
    private var layoutIntroItems: [[SearchItemProtocol]] {
        var items: [[SearchItemProtocol]] = []
        
        var counter = 1
        for _ in 0..<settings.rowCount {
            var rowItems: [SearchItemProtocol] = []
            for _ in 0..<settings.columnCount {
                // 0 for black color and no shape
                let item = SearchItem(identifier: "\(counter)", colorId: 0, shapeId: 0)
                rowItems.append(item)
                counter += 1
            }
            items.append(rowItems)
        }
        return items
    }
}
