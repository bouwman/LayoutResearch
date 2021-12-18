//
//  DashboardService.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 09.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import ResearchKit

class DashboardService: NSObject {
    var discreteGraphDataSource: DiscreteGraphDataSource
    var lineGraphDataSource: LineGraphDataSource
    var isDummyData: Bool
    
    override init() {
        if let dataPoints = DashboardService.layoutDataPoints {
            discreteGraphDataSource = DiscreteGraphDataSource(dataPoints: dataPoints)
            lineGraphDataSource = LineGraphDataSource(dataPoints: DashboardService.totalSearchTimeFor(discreteData: dataPoints))
            isDummyData = false
        } else {
            // Dummy data
            discreteGraphDataSource = DiscreteGraphDataSource()
            lineGraphDataSource = LineGraphDataSource()
            isDummyData = true
        }
        super.init()
    }
    
    // MARK: - Helper
    
    func reloadDataSources() {
        if let dataPoints = DashboardService.layoutDataPoints {
            discreteGraphDataSource = DiscreteGraphDataSource(dataPoints: dataPoints)
            lineGraphDataSource = LineGraphDataSource(dataPoints: DashboardService.totalSearchTimeFor(discreteData: dataPoints))
            isDummyData = false
        } else {
            // Dummy data
            discreteGraphDataSource = DiscreteGraphDataSource()
            lineGraphDataSource = LineGraphDataSource()
            isDummyData = true
        }
    }
    
    private static func totalSearchTimeFor(discreteData: [[ORKValueRange]]) -> [[ORKValueRange]] {
        var dataPoints: [[ORKValueRange]] = []
        var avgsForEachDay: [[Double]] = []
        
        // Create a row for each day
        for _ in discreteData.first! {
            let row: [Double] = []
            avgsForEachDay.append(row)
        }
        
        // Save avg for each layout per day
        for layoutDataPoints in discreteData {
            for (day, dataPoint) in layoutDataPoints.enumerated() {
                avgsForEachDay[day].append(dataPoint.maximumValue)
            }
        }
        
        // Calc avg for each day and add to result array
        for day in avgsForEachDay {
            var dailySum = 0.0
            for layoutAvg in day {
                dailySum += layoutAvg
            }
            let dailyAvg = dailySum / Double(day.count)
            let plotValue = dailyAvg.isNaN ? ORKValueRange() : ORKValueRange(value: dailyAvg)
            if var firstPlot = dataPoints.first {
                firstPlot.append(plotValue)
                dataPoints[0] = firstPlot
            } else {
                let newPlotRow: [ORKValueRange] = [plotValue]
                dataPoints.append(newPlotRow)
            }
        }
        
        return dataPoints
    }
    
    private static var layoutDataPoints: [[ORKValueRange]]? {
        var graphValues: [[ORKValueRange]] = []
        var dataPoints: [[Double]] = []
        
        // Create a plot row for each layout
        for _ in 0...1 {
            let dataRow: [Double] = []
            dataPoints.append(dataRow)
        }
        
        // Get latest values
        for i in 0..<Const.StudyParameters.searchActivityCount {
            let gridAvgFromDefaults = UserDefaults.standard.double(forKey: SettingsString.avgTimeGridResult.rawValue + "\(i)")
            let horAvgFromDefaults = UserDefaults.standard.double(forKey: SettingsString.avgTimeHorResult.rawValue + "\(i)")
            
            if gridAvgFromDefaults != 0 && gridAvgFromDefaults.isNaN == false {
                dataPoints[0].append(gridAvgFromDefaults)
            }
            if horAvgFromDefaults != 0 && horAvgFromDefaults.isNaN == false {
                dataPoints[1].append(horAvgFromDefaults)
            }
        }
        
        guard dataPoints.first!.count != 0 else {
            return nil
        }
        
        // Find minimum
        var min = dataPoints.first!.first!
        for plot in dataPoints {
            if let localMin = plot.min(), localMin < min {
                min = localMin
            }
        }
        
        // Map to graph values
        for plot in dataPoints {
            let newGraphPlot = plot.map { ORKValueRange(minimumValue: min - Const.Interface.graphOffset, maximumValue: $0) }
            graphValues.append(newGraphPlot)
        }
        
        return graphValues
    }
}
