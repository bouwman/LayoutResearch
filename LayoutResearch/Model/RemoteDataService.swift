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
    struct SurveyResult {
        static let typeName = "SurveyResult"
        static let user = "user"
        static let preferredLayout = "preferredLayout"
    }
    struct RewardSignup {
        static let typeName = "RewardSignup"
        static let user = "user"
        static let email = "email"
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
        
    func isSearchResultUploaded(resultNumber: Int) -> Bool {
        return UserDefaults.standard.bool(forKey: SettingsString.searchResultWasUploaded.rawValue + "\(resultNumber)")
    }
    
    var isSurveyResultUploaded: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SettingsString.surveyResultWasUploaded.rawValue)
        }
        get {
            return UserDefaults.standard.bool(forKey: SettingsString.surveyResultWasUploaded.rawValue)
        }
    }
    
    var isParticipantsEmailUploaded: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SettingsString.participantsEmailWasUploaded.rawValue)
        }
        get {
            return UserDefaults.standard.bool(forKey: SettingsString.participantsEmailWasUploaded.rawValue)
        }
    }
    
    func setIsResultUploadedFor(resultNumber: Int, isResultUploaded: Bool) {
        UserDefaults.standard.set(isResultUploaded, forKey: SettingsString.searchResultWasUploaded.rawValue + "\(resultNumber)")
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                // Try fetch again
                                self.fetchLastSettings(completion: completion)
                            }
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
    
    func uploadStudyResult(resultNumber: Int, group: ParticipantGroup, csvURL: URL, completion: @escaping (Error?) -> ()) {
        container.fetchUserRecordID { (userId, errorUser) in
            guard let userId = userId else {
                completion(errorUser)
                return
            }
            
            // Setup records
            var records: [CKRecord] = []
            let resultRecord = CKRecord(recordType: CloudRecords.StudyResult.typeName)
            
            resultRecord[CloudRecords.StudyResult.user] = CKReference(recordID: userId, action: .none)
            resultRecord[CloudRecords.StudyResult.csvFile] = CKAsset(fileURL: csvURL)
            records.append(resultRecord)
            
            // Upload last settings if first activity
            if resultNumber == 0 {
                let settingsRecord = self.settingsRecordFor(participantGroup: group)
                records.append(settingsRecord)
            }
            
            // Create operation
            let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
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
            let consentRecord = CKRecord(recordType: CloudRecords.ConsentForm.typeName)
            
            consentRecord[CloudRecords.ConsentForm.user] = CKReference(recordID: userId, action: .none)
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
    
    func uploadSurveyResult(preferredLayout: String, completion: @escaping (Error?) -> ()) {
        container.fetchUserRecordID { (userId, errorUser) in
            guard let userId = userId else {
                completion(errorUser)
                return
            }
            let surveyRecord = CKRecord(recordType: CloudRecords.SurveyResult.typeName)
            
            surveyRecord[CloudRecords.SurveyResult.user] = CKReference(recordID: userId, action: .none)
            surveyRecord[CloudRecords.SurveyResult.preferredLayout] = preferredLayout as NSString
            
            let operation = CKModifyRecordsOperation(recordsToSave: [surveyRecord], recordIDsToDelete: nil)
            operation.qualityOfService = .userInitiated
            
            operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                if let error = error {
                    completion(error)
                } else {
                    self.isSurveyResultUploaded = true
                    completion(error)
                }
            }
            
            self.publicDB.add(operation)
        }
    }
    
    func uploadEmail(participantsEmail: String, completion: @escaping (Error?) -> ()) {
        container.fetchUserRecordID { (userId, errorUser) in
            guard let userId = userId else {
                completion(errorUser)
                return
            }
            let rewardRecord = CKRecord(recordType: CloudRecords.RewardSignup.typeName)
            
            rewardRecord[CloudRecords.RewardSignup.user] = CKReference(recordID: userId, action: .none)
            rewardRecord[CloudRecords.RewardSignup.email] = participantsEmail as NSString
            
            let operation = CKModifyRecordsOperation(recordsToSave: [rewardRecord], recordIDsToDelete: nil)
            operation.qualityOfService = .userInitiated
            
            operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                if let error = error {
                    completion(error)
                } else {
                    self.isParticipantsEmailUploaded = true
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
