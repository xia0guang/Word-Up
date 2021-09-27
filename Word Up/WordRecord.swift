//
//  WordRecord.swift
//  Word Up
//
//  Created by Ray Wu on 9/25/21.
//

import Foundation
import CloudKit

let keyContent = "Content"
let keyReviewCount = "ReviewCount"
let keyAdded = "Added"
let keyLastReviewed = "LastReviewed"
let keyNextToBeReviewed = "NextToBeReviewed"
let keyNextToBeReviewedDay = "NextToBeReviewedDay"
let keyNextToBeReviewedMonth = "NextToBeReviewedMonth"

struct WordRecord {
    static let recordName = "word"
    
    
    let content: String
    let added: Date
    var reviewCount: Int
    var lastReviewed: Date?
    var nextToBeReviewed: Date?
    
    var nextToBeReviewedDay: Int? {
        guard let nextToBeReviewed = nextToBeReviewed else {
            return nil
        }
        
        return Calendar.current.component(.day, from: nextToBeReviewed)
    }
    
    var nextToBeReviewedMonth: Int? {
        guard let nextToBeReviewed = nextToBeReviewed else {
            return nil
        }
        
        return Calendar.current.component(.month, from: nextToBeReviewed)
    }
    
    init?(_ entry: CKRecord) {
        guard let wordContent = entry[keyContent] as? String, !wordContent.isEmpty,
              let reviewCount = entry[keyReviewCount] as? Int,
              let added = entry[keyAdded] as? Date else {
            //TODO: - Error Handle
            print("this is not a valid word record")
            return nil
        }
        
        self.content = wordContent
        self.reviewCount = reviewCount
        self.added = added

        self.lastReviewed = entry[keyLastReviewed] as? Date
        self.nextToBeReviewed = entry[keyNextToBeReviewed] as? Date
    }
    
    init(content: String, added: Date) {
        self.content = content
        self.added = added
        self.reviewCount = 0
        
        //set word for tomorrow to be reviewed
        let currentTime = Date()
        self.nextToBeReviewed = Calendar.current.date(byAdding: .day, value: 1, to: currentTime)
        
    }
    
    func serialized() -> CKRecord {
        let record = CKRecord(recordType: Config.wordRecordType, recordID: CKRecord.ID(recordName: WordRecord.recordName))
        record[keyContent] = content
        record[keyReviewCount] = reviewCount
        record[keyAdded] = added
        record[keyLastReviewed] = lastReviewed
        record[keyNextToBeReviewed] = nextToBeReviewed
        record[keyNextToBeReviewedDay] = nextToBeReviewedDay
        record[keyNextToBeReviewedMonth] = nextToBeReviewedMonth
        
        return record
    }
    
    func reviewIncreased(_ count: Int) -> WordRecord {
        var newWord = self
        newWord.reviewCount += 1
        
        return newWord
    }
    
    func reviewed(at reviewedDate: Date) -> WordRecord {
        var newWord = reviewIncreased(1)
        newWord.lastReviewed = reviewedDate
        
        return newWord
    }

}
