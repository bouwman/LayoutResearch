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
    struct StudyResult {
        static let typeName = "StudyResult"
        static let user = "user"
        static let consentFile = "consentFile"
        static let csvFile = "csvFile"
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
    
    func fetchLastSettings(completion: @escaping (ParticipantGroup?, CKRecord?, Error?) -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: CloudRecords.StudySettings.typeName, predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInitiated
        operation.resultsLimit = 1
        operation.desiredKeys = [CloudRecords.StudySettings.group]
        
        operation.recordFetchedBlock = { record in
            if let groupString = record.object(forKey: CloudRecords.StudySettings.group) as? String {
                completion(ParticipantGroup(rawValue: groupString), record, nil)
            } else {
                completion(nil, nil, nil)
            }
        }
        
        operation.queryCompletionBlock = { cursor, error in
            if let error = error {
                completion(nil, nil, error)
            }
        }
        
        publicDB.add(operation)
    }
    
    func uploadLastSettings(_ newGroup: ParticipantGroup, completion: @escaping (Error?) -> ()) {
        fetchLastSettings { (group, record, error) in
            if let record = record {
                
                record[CloudRecords.StudySettings.group] = NSString(string: newGroup.rawValue)
                
                let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
                operation.qualityOfService = .userInitiated
                
                operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                    completion(error)
                }
                
                self.publicDB.add(operation)
            }
        }
    }
    
    func uploadStudyResults(csvURL: URL, consentURL: URL, completion: @escaping (Error?) -> ()) {
        container.fetchUserRecordID { (userId, errorUser) in
            guard let userId = userId else {
                completion(errorUser)
                return
            }
            let record = CKRecord(recordType: CloudRecords.StudyResult.typeName)
            
            record[CloudRecords.StudyResult.user] = CKReference(recordID: userId, action: .deleteSelf)
            record[CloudRecords.StudyResult.consentFile] = CKAsset(fileURL: consentURL)
            record[CloudRecords.StudyResult.csvFile] = CKAsset(fileURL: csvURL)
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.qualityOfService = .userInitiated
            
            operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                completion(error)
            }
            
            self.publicDB.add(operation)
        }
    }
}
