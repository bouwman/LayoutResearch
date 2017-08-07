//
//  FileService.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 27.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

class LocalDataService {
    let docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last!
    var consentPath: URL { return docURL.appendingPathComponent("signature.pdf") }
    
    var existingResultsPaths: [URL] {
        var urls: [URL] = []
        for i in 0..<Const.StudyParameters.searchActivityCount {
            if resultFileExists(resultNumber: i) {
                let url = docURL.appendingPathComponent("result\(i).csv")
                urls.append(url)
            }
        }
        return urls
    }
    
    func existingPathFor(resultNumber: Int) -> URL? {
        return resultFileExists(resultNumber: resultNumber) ? docURL.appendingPathComponent("result\(resultNumber).csv") : nil
    }
    
    func createPathFor(resultNumber: Int) -> URL? {
        return resultFileExists(resultNumber: resultNumber) ? nil : docURL.appendingPathComponent("result\(resultNumber).csv")
    }
    
    var lastActivityCompletionDate: Date? {
        let savedTime = UserDefaults.standard.double(forKey: SettingsString.lastActivityCompletionDate.rawValue)
        return savedTime == 0 ? nil : Date(timeIntervalSinceReferenceDate: savedTime)
    }
    
    func saveConsent(data: Data?) {
        try! data?.write(to: consentPath)
        
        // Save path
        UserDefaults.standard.set(true, forKey: SettingsString.isParticipating.rawValue)
        UserDefaults.standard.set(consentPath, forKey: SettingsString.consentPath.rawValue)
    }
    
    var areResultsAvailable: Bool {
        return existingResultsPaths.count != 0
    }
    
    var isConsentAvailable: Bool {
        return FileManager.default.fileExists(atPath: consentPath.path)
    }
    
    func removeResultIfExist(resultNumber: Int) {
        if let existingURL = existingPathFor(resultNumber: resultNumber) {
            try! FileManager.default.removeItem(at: existingURL)
        }
    }
    
    func removeAllResults() {
        for url in existingResultsPaths {
            try! FileManager.default.removeItem(at: url)
        }
    }
    
    func removeConsentIfExists() {
        if isConsentAvailable {
            try! FileManager.default.removeItem(at: consentPath)
            UserDefaults.standard.removeObject(forKey: SettingsString.consentPath.rawValue)
        }
    }
    
    func resultFileExists(resultNumber: Int) -> Bool {
        return FileManager.default.fileExists(atPath: docURL.appendingPathComponent("result\(resultNumber).csv").path)
    }
}
