//
//  WatchDataManager.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 15.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import WatchConnectivity
import UIKit

class WatchDataManager: NSObject, WCSessionDelegate {
    
    static let watchManager = WatchDataManager()
    override init() {
        super.init()
    }
    
    lazy private var dataManager: DataManager? = { return UIApplication.appDelegate().dataManager }()
    private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
    private var validSession: WCSession? {
        if let session = session where session.paired && session.watchAppInstalled {
            return session
        }
        return nil
    }
    
    func startSession() {
        session?.delegate = self
        session?.activateSession()
    }
    
    ///Try sending decks array with deck IDs to AW, throws success or failure bool
    func sendDecksToAppleWatch(decksIDs: [String]) throws -> Bool {
        var outcome = false
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
        if let session = validSession {
            if !flashcardsQuestions.isEmpty && !flashcardsAnswers.isEmpty {
                do {
                    //let testData = ["TestQuestion1":"TestAnswer1", "TestQuestion2":"TestAnswer2",
                    //                "TestQuestion3":"TestAnswer3", "TestQuestion4":"TestAnswer4",
                    //                "TestQuestion5":"TestAnswer5", "TestQuestion6":"TestAnswer6"]
                    try session.updateApplicationContext(["flashcardsQuestions":flashcardsQuestions,"flashcardsAnswers":flashcardsAnswers])
                    outcome = true
                } catch let error {
                    print(error)
                    outcome = false
                }
            }
        }
        return outcome
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