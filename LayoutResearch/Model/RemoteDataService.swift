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
        static let preferredDensity = "preferredDensity"
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
    
    func fetchLeastUsedSetting(completion: @escaping (ParticipantGroup?, CKRecord.ID?, Error?) -> ()) {
        container.fetchUserRecordID { (userId, errorUser) in
            guard let userId = userId else {
                completion(nil, nil, errorUser)
                return
            }
            
            // Create a dictionary with all groups
            var groupCounts = [ParticipantGroup : Int]()
            for group in ParticipantGroup.allGroups {
                groupCounts[group] = 0
            }
            
            // Create operation
            let predicate = NSPredicate(value: true)
            let sortByCreationDate = NSSortDescriptor(key: CloudRecords.Universal.createdAt, ascending: false)
            let query = CKQuery(recordType: CloudRecords.StudySettings.typeName, predicate: predicate)
            let operation = CKQueryOperation(query: query)
            
            query.sortDescriptors = [sortByCreationDate]
            operation.qualityOfService = .userInitiated
            operation.resultsLimit = 500
            operation.desiredKeys = [CloudRecords.StudySettings.group]
            
            // Count number of participants (settings)
            var participantCount = 0
            
            operation.recordFetchedBlock = { record in
                if let groupString = record[CloudRecords.StudySettings.group] as? String, let group = ParticipantGroup(rawValue: groupString), let currentCount = groupCounts[group] {
                    participantCount += 1
                    groupCounts[group] = currentCount + 1
                }
            }
            
            operation.queryCompletionBlock = { cursor, error in
                if let error = error {
                    completion(nil, userId, error)
                } else {
                    if participantCount > 0 {
                        // Only pick among mandatory groups
                        if participantCount <= 24 {
                            for optionalGroup in ParticipantGroup.optionalGroups {
                                groupCounts.removeValue(forKey: optionalGroup)
                            }
                        } else {
                            for mandatoryGroup in ParticipantGroup.mandatoryGroups {
                                groupCounts.removeValue(forKey: mandatoryGroup)
                            }
                        }
                        // Find minimum value
                        if let min = groupCounts.min(by: { $0.value < $1.value }) {
                            let minGroup: ParticipantGroup
                            let multipleMins = groupCounts.filter { $0.value == min.value }
                            
                            // Pick random if multiple mins are found
                            if multipleMins.count > 1 {
                                let minGroups = multipleMins.map { $0.key }
                                minGroup = minGroups.shuffled().first!
                            } else {
                                minGroup = min.key
                            }
                            completion(minGroup, userId, nil)
                        } else {
                            completion(nil, userId, nil)
                        }
                    } else {
                        // No records found so pick random
                        let randomGroup = ParticipantGroup.randomMandatory
                        completion(randomGroup, userId, nil)
                    }
                }
            }
            
            self.publicDB.add(operation)
        }
    }
    
    func fetchLastSettings(completion: @escaping (ParticipantGroup?, CKRecord?, CKRecord.ID?, Error?) -> ()) {
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
    
    func uploadStudyResult(participantId: String, resultNumber: Int, group: ParticipantGroup, csvURL: URL, consentURL: URL, completion: @escaping (Error?) -> ()) {
        container.fetchUserRecordID { (userId, errorUser) in
            guard let userId = userId else {
                completion(errorUser)
                return
            }
            let idString = String(participantId.prefix(8)) + "-attempt\(resultNumber)"
            let recordId = CKRecord.ID(recordName: idString)
            let fetchExistingOperation = CKFetchRecordsOperation(recordIDs: [recordId])
            
            fetchExistingOperation.fetchRecordsCompletionBlock = { fetchedRecords, error in
                // Record already exists
                if let fetchedRecords = fetchedRecords, fetchedRecords.count > 0 {
                    completion(nil)
                }
                else if let _ = error { // No record online yet
                    let uploadResultOperation = self.createUploadStudyResultOperation(userId: userId, resultRecordId: recordId, resultNumber: resultNumber, group: group, csvURL: csvURL, consentURL: consentURL, completion: completion)
                    self.publicDB.add(uploadResultOperation)
                }
            }
            
            self.publicDB.add(fetchExistingOperation)
        }
    }
    
    func uploadConsentForm(consentURL: URL, completion: @escaping (Error?) -> ()) {
        container.fetchUserRecordID { (userId, errorUser) in
            guard let userId = userId else {
                completion(errorUser)
                return
            }
            let consentRecord = CKRecord(recordType: CloudRecords.ConsentForm.typeName)
            
            consentRecord[CloudRecords.ConsentForm.user] = CKRecord.Reference(recordID: userId, action: .none)
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
    
    func uploadSurveyResult(preferredLayout: String, preferredDensity: String, completion: @escaping (Error?) -> ()) {
        container.fetchUserRecordID { (userId, errorUser) in
            guard let userId = userId else {
                completion(errorUser)
                return
            }
            let surveyRecord = CKRecord(recordType: CloudRecords.SurveyResult.typeName)
            
            surveyRecord[CloudRecords.SurveyResult.user] = CKRecord.Reference(recordID: userId, action: .none)
            surveyRecord[CloudRecords.SurveyResult.preferredLayout] = preferredLayout as NSString
            surveyRecord[CloudRecords.SurveyResult.preferredDensity] = preferredDensity as NSString
            
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
            
            rewardRecord[CloudRecords.RewardSignup.user] = CKRecord.Reference(recordID: userId, action: .none)
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
                let subscription = CKQuerySubscription(recordType: CloudRecords.StudySettings.typeName, predicate: predicate, options: .firesOnRecordCreation)
                let notification = CKSubscription.NotificationInfo()
                
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
    
    private func createUploadStudyResultOperation(userId: CKRecord.ID, resultRecordId: CKRecord.ID, resultNumber: Int, group: ParticipantGroup, csvURL: URL, consentURL: URL, completion: @escaping (Error?) -> ()) -> CKModifyRecordsOperation {
        
        // Setup records
        var records: [CKRecord] = []
        let resultRecord = CKRecord(recordType: CloudRecords.StudyResult.typeName, recordID: resultRecordId)
        
        resultRecord[CloudRecords.StudyResult.user] = CKRecord.Reference(recordID: userId, action: .none)
        resultRecord[CloudRecords.StudyResult.csvFile] = CKAsset(fileURL: csvURL)
        records.append(resultRecord)
        
        // Upload last settings and consent if first activity
        if resultNumber == 0 {
            let settingsRecord = self.settingsRecordFor(participantGroup: group)
            let consentRecord = CKRecord(recordType: CloudRecords.ConsentForm.typeName)
            
            consentRecord[CloudRecords.ConsentForm.user] = CKRecord.Reference(recordID: userId, action: .none)
            consentRecord[CloudRecords.ConsentForm.pdf] = CKAsset(fileURL: consentURL)
            
            records.append(settingsRecord)
            records.append(consentRecord)
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
        return operation
    }
}
