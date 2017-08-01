//
//  RemoteDataService.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 01.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import CloudKit

private struct CloudRecords {
    struct StudySettings {
        static let typeName = "StudySettings"
        static let group = "group"
    }
}

class RemoteDataService {
    let container: CKContainer
    let publicDB: CKDatabase
    
    init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
    }
    
    static var isICloudContainerAvailable: Bool {
        return FileManager.default.ubiquityIdentityToken != nil
    }
    
    func fetchLastSettings(completion: @escaping (ParticipantGroup?, Error?) -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: CloudRecords.StudySettings.typeName, predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInitiated
        operation.resultsLimit = 1
        operation.desiredKeys = [CloudRecords.StudySettings.group]
        
        operation.recordFetchedBlock = { record in
            if let groupString = record.object(forKey: CloudRecords.StudySettings.group) as? String {
                completion(ParticipantGroup(rawValue: groupString), nil)
            } else {
                completion(nil, nil)
            }
        }
        
        operation.queryCompletionBlock = { cursor, error in
            if let error = error {
                completion(nil, error)
            }
        }
        
        publicDB.add(operation)
    }
}
