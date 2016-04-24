//
//  WatchDataManager.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 15.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import WatchConnectivity
import UIKit

enum SendingToWatchResult: ErrorType {
    case Success, Failure
}

//WatchDataManager is implemented because updating the Watch data will occur in Settings and later when user edits a deck or flashcard data.
class WatchDataManager: NSObject, WCSessionDelegate {
    
    static let watchManager = WatchDataManager()
    private var dataManager: DataManager? = { return UIApplication.appDelegate().dataManager }()
    private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
    private var validSession: WCSession? {
        if let session = session where session.paired && session.watchAppInstalled {
            return session
        }
        return nil
    }
    
    override init() {
        super.init()
    }
    
    func startSession() {
        session?.delegate = self
        session?.activateSession()
    }
    
    //Sends an array with deck IDs to Apple Watch
    func sendDecksToAppleWatch(decksIDs: [String]) throws {
        
        var flashcardsQuestions = [String]()
        var flashcardsAnswers = [String]()
        
        if let manager = dataManager {
            for deck in decksIDs {
                if let deckFromManager = manager.deck(withId: deck) {
                    for flashcard in deckFromManager.flashcards {
                        flashcardsQuestions.append(flashcard.question)
                        flashcardsAnswers.append(flashcard.answer)
                    }
                }
            }
        }
        
//        //Dummy Data
//        flashcardsQuestions = ["1\n" + String(NSDate()), "2\n" + String(NSDate()), "3\n" + String(NSDate()), "TestQuestion4", "TestQuestion5"]
//        flashcardsAnswers = ["TestAnswer1", "TestAnswer2", "TestAnswer3", "long\nTestAnswer4\nvery\nvery\nvery\nvery\nlong", "TestAnswer5"]
//
        if !flashcardsQuestions.isEmpty && !flashcardsAnswers.isEmpty {
            do {
                try self.updateApplicationContext(["flashcardsQuestions":flashcardsQuestions, "flashcardsAnswers":flashcardsAnswers])
            } catch let error {
                print("Sending to Watch failed: \(error)")
                throw error
            }
        }
    }
}

extension WatchDataManager {
    func updateApplicationContext(applicationContext: [String : AnyObject]) throws {
        if let session = validSession {
            do {
                try session.updateApplicationContext(applicationContext)
            } catch let error {
                throw error
            }
        }
    }
}
