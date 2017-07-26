//
//  ResultService.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 26.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import Foundation

class ResultService {
    let docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last!
    var csvFilePath: URL { return docURL.appendingPathComponent("result.csv") }
    
    var isResultAvailable: Bool {
        return FileManager.default.fileExists(atPath: csvFilePath.path)
    }
    
    var lastResults: [SearchResult]? {
        didSet {
            if let results = lastResults {
                saveResultsToCSV(results: results)
            }
        }
    }
    
    func saveResultsToCSV(results: [SearchResult]) {
        guard results.count != 0 else { return }
        
        // Remove old if existent
        if isResultAvailable {
            try! FileManager.default.removeItem(at: csvFilePath)
        }
        
        let optionalSream = OutputStream(url: csvFilePath, append: false)
        
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
            UserDefaults.standard.set(csvFilePath, forKey: SettingsString.resultCSVPath.rawValue)
        } catch {
            print("Error writing csv")
        }
    }
}
