//
//  ViewModel.swift
//  Word Up
//
//  Created by Ray Wu on 9/25/21.
//

import Foundation
import CloudKit
import Combine
import UIKit
import os.log

class ViewModel: ObservableObject {
    private let container = CKContainer(identifier: Config.containerIdentifier)
    private lazy var database = container.privateCloudDatabase
    
    //MARK: - API
    
    func queryToday() -> Future<[WordRecord], Never> {
        return Future() { promise in
            
            let currentTime = Date()
            let today = Calendar.current.component(.day, from: currentTime)
            let thisMonth = Calendar.current.component(.month, from: currentTime)
            let wordPredicate = NSPredicate(format: "(nextToBeReviewedDay == %@) AND (nextToBeReviewedMonth == %@)", today, thisMonth)
//            let wordPredicate = NSPredicate(format: "Content == %@", "apple")
            let wordQuery = CKQuery(recordType: Config.wordRecordType, predicate: wordPredicate)
            self.database.perform(wordQuery, inZoneWith: .default) { results, error in
                if let error = error {
                    self.reportError(error)
                    return
                }
                guard let results = results else {
                    //TODO: - Error Handle
                    os_log("No words find for today")
                    return
                }
                
                var wordList: [WordRecord] = []
                for entry in results {
                    guard let newWord = WordRecord(entry) else {
                        continue
                    }
                    wordList.append(newWord)
                }
                
                
                promise(Result.success(wordList))
            }
        }
    }
    
    func addWord(_ word: WordRecord) -> Future<CKRecord, Never> {
        return Future() { promise in
            
            let newWordRecord = word.serialized()
            self.database.save(newWordRecord) { record, error in
                if let error = error {
                    self.reportError(error)
                    return
                    
                } else {
                    guard let record = record else {
                        return
                    }
                    
                    os_log("Record with ID \(record.recordID) was saved")
                    promise(Result.success(record))
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func reportError(_ error: Error) {
        guard let ckerror = error as? CKError else {
            os_log("Not a CKError: \(error.localizedDescription)")
            return
        }

        switch ckerror.code {
        case .partialFailure:
            // Iterate through error(s) in partial failure and report each one.
            let dict = ckerror.userInfo[CKPartialErrorsByItemIDKey] as? [NSObject: CKError]
            if let errorDictionary = dict {
                for (_, error) in errorDictionary {
                    reportError(error)
                }
            }

        // This switch could explicitly handle as many specific errors as needed, for example:
        case .unknownItem:
            os_log("CKError: Record not found.")

        case .notAuthenticated:
            os_log("CKError: An iCloud account must be signed in on device or Simulator to write to a PrivateDB.")

        case .permissionFailure:
            os_log("CKError: An iCloud account permission failure occured.")

        case .networkUnavailable:
            os_log("CKError: The network is unavailable.")

        default:
            os_log("CKError: \(error.localizedDescription)")
        }
    }
}
