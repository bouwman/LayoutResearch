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
    
    var attemptNumber: Int {
        return UserDefaults.standard.integer(forKey: SettingsString.attemptNumber.rawValue)
    }
    
    var existingResultsPaths: [URL] {
        var urls: [URL] = []
        for i in 0...attemptNumber {
            if resultFileExists(resultNumber: i) {
                let url = docURL.appendingPathComponent("result\(i).csv")
                urls.append(url)
            }
        }
        return urls
    }
    
    var mostRecentResultPath: URL? {
        return areResultsAvailable ? existingResultsPaths.last : nil
    }
    
    var newResultPath: URL {
        return docURL.appendingPathComponent("result\(attemptNumber).csv")
    }
    
    var firstActivityCompletionDate: Date? {
        let savedTime = UserDefaults.standard.double(forKey: SettingsString.firstActivityDate.rawValue)
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
    
    func removeResultsIfExist() {
        if areResultsAvailable {
            for url in existingResultsPaths {
                try! FileManager.default.removeItem(at: url)
            }
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
