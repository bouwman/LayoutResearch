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
        
        fileService.removeResultsIfExist()
        
        let optionalSream = OutputStream(url: fileService.newResultPath, append: false)
        
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
            
            // Save number
            attemptNumber += 1
        } catch {
            print("Error writing csv")
        }
    }
    
    var attemptNumber: Int {
        set {
            UserDefaults.standard.setValue(attemptNumber, forKey: SettingsString.attemptNumber.rawValue)
        }
        get {
            return UserDefaults.standard.integer(forKey: SettingsString.attemptNumber.rawValue)
        }
    }
    
    var isParticipantGroupAssigned: Bool {
        set {
            UserDefaults.standard.setValue(isParticipantGroupAssigned, forKey: SettingsString.isParticipantGroupAssigned.rawValue)
        }
        get {
            return UserDefaults.standard.bool(forKey: SettingsString.isParticipantGroupAssigned.rawValue)
        }
    }
}
