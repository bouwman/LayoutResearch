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
        static let csvFile = "csvFile"
    }
    struct ConsentForm {
        static let typeName = "ConsentForm"
        static let user = "user"
        static let pdf = "pdf"
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
        
    func isResultUploaded(resultNumber: Int) -> Bool {
        return UserDefaults.standard.bool(forKey: SettingsString.resultWasUploaded.rawValue + "\(resultNumber)")
    }
    
    func setIsResultUploadedFor(resultNumber: Int, isResultUploaded: Bool) {
        UserDefaults.standard.set(isResultUploaded, forKey: SettingsString.resultWasUploaded.rawValue + "\(resultNumber)")
    }
    
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
    
    func uploadStudyResult(resultNumber: Int, csvURL: URL, completion: @escaping (Error?) -> ()) {
        container.fetchUserRecordID { (userId, errorUser) in
            guard let userId = userId else {
                completion(errorUser)
                return
            }
            let resultRecord = CKRecord(recordType: CloudRecords.StudyResult.typeName)
            
            resultRecord[CloudRecords.StudyResult.user] = CKReference(recordID: userId, action: .deleteSelf)
            resultRecord[CloudRecords.StudyResult.csvFile] = CKAsset(fileURL: csvURL)
            
            let operation = CKModifyRecordsOperation(recordsToSave: [resultRecord], recordIDsToDelete: nil)
            operation.qualityOfService = .userInitiated
            
            operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                if let error = error {
                    completion(error)
                } else {
                    self.setIsResultUploadedFor(resultNumber: resultNumber, isResultUploaded: true)
                    completion(error)
                }
            }
            
            self.publicDB.add(operation)
        }
    }
    
    func uploadConsentForm(consentURL: URL, completion: @escaping (Error?) -> ()) {
        container.fetchUserRecordID { (userId, errorUser) in
            guard let userId = userId else {
                completion(errorUser)
                return
            }
            let consentRecord = CKRecord(recordType: CloudRecords.StudyResult.typeName)
            
            consentRecord[CloudRecords.ConsentForm.user] = CKReference(recordID: userId, action: .deleteSelf)
            consentRecord[CloudRecords.ConsentForm.pdf] = CKAsset(fileURL: consentURL)
            
            let operation = CKModifyRecordsOperation(recordsToSave: [consentRecord], recordIDsToDelete: nil)
            operation.qualityOfService = .userInitiated
            
            operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                if let error = error {
                    completion(error)
                } else {
                    completion(error)
                }
            }
            
            self.publicDB.add(operation)
        }
    }
    
    func subscribeToSettingsChangesIfNotDoneYet(completion: @escaping (Error?) -> ()) {
        publicDB.fetchAllSubscriptions { (subscriptions, error) in
            if let _ = subscriptions {
                // Alread exist
                completion(nil)
            } else if let error = error {
                completion(error)
            } else {
                // Create new
                let predicate = NSPredicate(value: true)
                let subscription = CKSubscription(recordType: CloudRecords.StudySettings.typeName, predicate: predicate, options: .firesOnRecordCreation)
                let notification = CKNotificationInfo()
                
                subscription.notificationInfo = notification
                
                self.publicDB.save(subscription) { (subscription, error) in
                    completion(error)
                }
            }
        }
    }
    
    // MARK: - Helper
    
    private func settingsRecordFor(participantGroup: ParticipantGroup) -> CKRecord {
        let record = CKRecord(recordType: CloudRecords.StudySettings.typeName)
        record[CloudRecords.StudySettings.group] = NSString(string: participantGroup.rawValue)
        
        return record
    }
}
