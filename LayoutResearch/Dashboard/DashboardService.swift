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
            var daylySum = 0.0
            for layoutAvg in day {
                daylySum += layoutAvg
            }
            let daylyAvg = daylySum / Double(day.count)
            var firstPlot = dataPoints.first!
            firstPlot.append(ORKValueRange(value: daylyAvg))
            dataPoints[0] = firstPlot
        }
        
        return dataPoints
    }
    
    private static var layoutDataPoints: [[ORKValueRange]]? {
        var dataPoints: [[ORKValueRange]] = []
        var isFirstDataAvailable = false
        
        // Get latest values
        for i in 0..<Const.StudyParameters.searchActivityCount {
            let gridAvgFromDefaults = UserDefaults.standard.double(forKey: SettingsString.avgTimeGridResult.rawValue + "\(i)")
            let horAvgFromDefaults = UserDefaults.standard.double(forKey: SettingsString.avgTimeHorResult.rawValue + "\(i)")
            let verAvgFromDefaults = UserDefaults.standard.double(forKey: SettingsString.avgTimeVerResult.rawValue + "\(i)")
            var plot: [ORKValueRange] = []
            
            if gridAvgFromDefaults != 0 {
                plot.append(ORKValueRange(minimumValue: 0, maximumValue: gridAvgFromDefaults))
                isFirstDataAvailable = true
            } else if isFirstDataAvailable {
                plot.append(ORKValueRange())
            }
            if horAvgFromDefaults != 0 {
                plot.append(ORKValueRange(minimumValue: 0, maximumValue: horAvgFromDefaults))
            } else if isFirstDataAvailable {
                plot.append(ORKValueRange())
            }
            if verAvgFromDefaults != 0 {
                plot.append(ORKValueRange(minimumValue: 0, maximumValue: verAvgFromDefaults))
            } else if isFirstDataAvailable {
                plot.append(ORKValueRange())
            }
            dataPoints.append(plot)
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
