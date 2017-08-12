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
        var dataPoints: [[ORKValueRange]] = []
        
        // Create a plot row for each layout
        for _ in 0...2 {
            let row: [ORKValueRange] = []
            dataPoints.append(row)
        }
        
        // Get latest values
        for i in 3..<Const.StudyParameters.searchActivityCount {
            let gridAvgFromDefaults = UserDefaults.standard.double(forKey: SettingsString.avgTimeGridResult.rawValue + "\(i)")
            let horAvgFromDefaults = UserDefaults.standard.double(forKey: SettingsString.avgTimeHorResult.rawValue + "\(i)")
            let verAvgFromDefaults = UserDefaults.standard.double(forKey: SettingsString.avgTimeVerResult.rawValue + "\(i)")
            
            if gridAvgFromDefaults != 0 && gridAvgFromDefaults.isNaN == false {
                dataPoints[0].append(ORKValueRange(minimumValue: 0, maximumValue: gridAvgFromDefaults))
            }
            if horAvgFromDefaults != 0 && horAvgFromDefaults.isNaN == false {
                dataPoints[1].append(ORKValueRange(minimumValue: 0, maximumValue: horAvgFromDefaults))
            }
            if verAvgFromDefaults != 0 && verAvgFromDefaults.isNaN == false  {
                dataPoints[2].append(ORKValueRange(minimumValue: 0, maximumValue: verAvgFromDefaults))
            }
        }
        
        // Return data points
        if dataPoints.first!.count != 0 {
            return dataPoints
        } else {
            // Nil if not enough found
            return nil
        }
    }
}
