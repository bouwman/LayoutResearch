//
//  RemoteDataService.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 01.08.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import CloudKit

private struct CloudRecords {
    struct Universal {
        static let createdAt = "creationDate"
    }
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
    
    var fetchingTriedAgain = false
    
    func fetchLastSettings(completion: @escaping (ParticipantGroup?, CKRecord?, CKRecordID?, Error?) -> ()) {
        container.fetchUserRecordID { (userId, errorUser) in
            guard let userId = userId else {
                completion(nil, nil, nil, errorUser)
                return
            }
            
            // Create operation
            let predicate = NSPredicate(value: true)
            let sortByCreationDate = NSSortDescriptor(key: CloudRecords.Universal.createdAt, ascending: false)
            let query = CKQuery(recordType: CloudRecords.StudySettings.typeName, predicate: predicate)
            let operation = CKQueryOperation(query: query)
            var recordFetched = false
            
            query.sortDescriptors = [sortByCreationDate]
            operation.qualityOfService = .userInitiated
            operation.resultsLimit = 1
            operation.desiredKeys = [CloudRecords.StudySettings.group]
            
            operation.recordFetchedBlock = { record in
                if let groupString = record[CloudRecords.StudySettings.group] as? String {
                    recordFetched = true
                    completion(ParticipantGroup(rawValue: groupString), record, userId, nil)
                }
            }
                        
            operation.queryCompletionBlock = { cursor, error in
                if let error = error {
                    completion(nil, nil, userId, error)
                } else if recordFetched == false {
                    // No records found so create new
                    self.uploadLastSettings(.a, completion: { (error) in
                        if let error = error {
                            completion(nil, nil, userId, error)
                        } else {
                            // Try fetch again
                            self.fetchLastSettings(completion: completion)
                        }
                    })
                }
            }
            
            self.publicDB.add(operation)
        }
    }
    
    func uploadLastSettings(_ lastParticipantGroup: ParticipantGroup, completion: @escaping (Error?) -> ()) {
        let settingsRecord = settingsRecordFor(participantGroup: lastParticipantGroup)
        let operation = CKModifyRecordsOperation(recordsToSave: [settingsRecord], recordIDsToDelete: nil)
        operation.qualityOfService = .userInitiated
        
        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            completion(error)
        }
        
        publicDB.add(operation)
    }
    
    func uploadStudyResults(participantGroup: ParticipantGroup, csvURL: URL, consentURL: URL, completion: @escaping (Error?) -> ()) {
        container.fetchUserRecordID { (userId, errorUser) in
            guard let userId = userId else {
                completion(errorUser)
                return
            }
            let resultRecord = CKRecord(recordType: CloudRecords.StudyResult.typeName)
            let settingsRecord = self.settingsRecordFor(participantGroup: participantGroup)
            
            resultRecord[CloudRecords.StudyResult.user] = CKReference(recordID: userId, action: .deleteSelf)
            resultRecord[CloudRecords.StudyResult.consentFile] = CKAsset(fileURL: consentURL)
            resultRecord[CloudRecords.StudyResult.csvFile] = CKAsset(fileURL: csvURL)
            
            let operation = CKModifyRecordsOperation(recordsToSave: [resultRecord, settingsRecord], recordIDsToDelete: nil)
            operation.qualityOfService = .userInitiated
            
            operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                completion(error)
            }
            
            self.publicDB.add(operation)
        }
    }
    
    private func settingsRecordFor(participantGroup: ParticipantGroup) -> CKRecord {
        let record = CKRecord(recordType: CloudRecords.StudySettings.typeName)
        record[CloudRecords.StudySettings.group] = NSString(string: participantGroup.rawValue)
        
        return record
    }
    
    func subscribeToSettingsChanges(completion: @escaping (Error?) -> ()) {
        let predicate = NSPredicate(value: true)
        let subscription = CKSubscription(recordType: CloudRecords.StudySettings.typeName, predicate: predicate, options: .firesOnRecordCreation)
        let notification = CKNotificationInfo()
        
        notification.alertBody = "New settings were added"
        notification.shouldBadge = true
        subscription.notificationInfo = notification
        
        publicDB.save(subscription) { (subscription, error) in
            completion(error)
        }
    }
}
