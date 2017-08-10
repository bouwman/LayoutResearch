//
//  ResultService.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 26.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import Foundation

class ResultService {
    let fileService = LocalDataService()
    
    func saveSearchResultToCSV(resultNumber: Int, results: [SearchResult]) {
        guard results.count != 0 else { return }
        
        fileService.removeResultIfExist(resultNumber: resultNumber)
        
        guard let url = fileService.createPathFor(resultNumber: resultNumber) else { return }
        
        let optionalSream = OutputStream(url: url, append: false)
        
        guard let stream = optionalSream else { return }
        
        do {
            let writer = try CSVWriter(stream: stream)
            
            // Add headline
            try writer.write(row: results.first!.csvHeadlines)
            
            // Add rows
            for result in results {
                try writer.write(row: result.csvRow)
            }
            
            writer.stream.close()
        } catch {
            print("Error writing csv")
        }
    }
    
    func saveAvgSearchTimesFor(resultNumber: Int, results: [SearchResult]) {
        var gridSum = 0.0
        var horiSum = 0.0
        var vertSum = 0.0
        
        var gridCount = 0
        var horiCount = 0
        var vertCount = 0
        
        for result in results {
            if let searchTime = result.searchTime, result.isError == false, result.isPractice == false, searchTime != 0 {
                switch result.layout {
                case .grid:
                    gridSum += searchTime
                    gridCount += 1
                case .horizontal:
                    horiSum += searchTime
                    horiCount += 1
                case .vertical:
                    vertSum += searchTime
                    vertCount += 1
                }
            }
        }
        
        
        let gridAvg = gridCount > 0 ? gridSum / Double(gridCount) : 0
        let horiAvg = horiCount > 0 ? horiSum / Double(horiCount) : 0
        let vertAvg = vertCount > 0 ? horiSum / Double(horiCount) : 0
        
        UserDefaults.standard.set(gridAvg, forKey: SettingsString.avgTimeGridResult.rawValue + "\(resultNumber)")
        UserDefaults.standard.set(horiAvg, forKey: SettingsString.avgTimeHorResult.rawValue + "\(resultNumber)")
        UserDefaults.standard.set(vertAvg, forKey: SettingsString.avgTimeVerResult.rawValue + "\(resultNumber)")
    }
}
