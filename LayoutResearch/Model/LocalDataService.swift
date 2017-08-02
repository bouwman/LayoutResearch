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
    var csvFilePath: URL { return docURL.appendingPathComponent("result.csv") }
    var consentPath: URL { return docURL.appendingPathComponent("signature.pdf") }
    
    func saveConsent(data: Data?) {
        try! data?.write(to: consentPath)
        
        // Save path
        UserDefaults.standard.set(true, forKey: SettingsString.isParticipating.rawValue)
        UserDefaults.standard.set(consentPath, forKey: SettingsString.consentPath.rawValue)
    }
    
    var isResultAvailable: Bool {
        return FileManager.default.fileExists(atPath: csvFilePath.path)
    }
    
    var isConsentAvailable: Bool {
        return FileManager.default.fileExists(atPath: consentPath.path)
    }
    
    func removeResultIfExists() {
        if isResultAvailable {
            try! FileManager.default.removeItem(at: csvFilePath)
            UserDefaults.standard.removeObject(forKey: SettingsString.resultCSVPath.rawValue)
        }
    }
    
    func removeConsentIfExists() {
        if isConsentAvailable {
            try! FileManager.default.removeItem(at: consentPath)
            UserDefaults.standard.removeObject(forKey: SettingsString.consentPath.rawValue)
        }
    }
}
