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
}
