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
    
    var lastResults: [SearchResult]? {
        didSet {
            if let results = lastResults {
                saveResultsToCSV(results: results)
            }
        }
    }
    
    func saveResultsToCSV(results: [SearchResult]) {
        guard results.count != 0 else { return }
        
        fileService.removeResultIfExists()
        
        let optionalSream = OutputStream(url: fileService.csvFilePath, append: false)
        
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
            
            // Save url
            UserDefaults.standard.set(fileService.csvFilePath, forKey: SettingsString.resultCSVPath.rawValue)
        } catch {
            print("Error writing csv")
        }
    }
}
