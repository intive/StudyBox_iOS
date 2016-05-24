//
//  WatchDataManager.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 15.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import WatchConnectivity
import UIKit

enum DecksSyncingResult {
    case Success, Failure
}

//WatchDataManager is implemented because updating the Watch data will occur in Settings and later when user edits a deck or flashcard data.
class WatchDataManager: NSObject, WCSessionDelegate {
    
    static let watchManager = WatchDataManager()
    private var dataManager: DataManager = { return UIApplication.appDelegate().dataManager }()
    private let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    let defaults = NSUserDefaults.standardUserDefaults()
    
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
    
    //Sends an array with deck IDs to Apple Watch
    func sendDecksToAppleWatch(decksIDs: [String]) throws {
        
        var flashcardsQuestions = [String]()
        var flashcardsAnswers = [String]()
        var flashcardsIDs = [String]()
        //This is an array of arrays because one flashcard can contain multiple tips
        var flashcardsTips = [[String]]()
        
        for deck in decksIDs {
            if let deckFromManager = dataManager.localDataManager.get(Deck.self, withId: deck) {
                for flashcard in deckFromManager.flashcards where !flashcard.hidden {
                    flashcardsQuestions.append(flashcard.question)
                    flashcardsAnswers.append(flashcard.answer)
                    flashcardsIDs.append(flashcard.serverID)
                    flashcardsTips.append(dataManager.localDataManager.tips(deck, flashcardID: flashcard.serverID).map({$0.content}))
                }
            }
        }
        
        if !flashcardsQuestions.isEmpty && !flashcardsAnswers.isEmpty {
            do {
                try self.updateApplicationContext([
                    Utils.WatchAppContextType.FlashcardsQuestions: flashcardsQuestions,
                    Utils.WatchAppContextType.FlashcardsAnswers: flashcardsAnswers,
                    Utils.WatchAppContextType.FlashcardsIDs: flashcardsIDs,
                    Utils.WatchAppContextType.FlashcardsTips: flashcardsTips])
            } catch let error {
                print("Sending to Watch failed: \(error)")
                throw error
            }
        }
    }
    
    func downloadSelectedDecksFlashcardsTips(decksToSync: [String], completion: (DecksSyncingResult) -> ()) {
        
        let group = dispatch_group_create()
        
        for deckID in decksToSync {
        dispatch_group_enter(group)
            
            dataManager.flashcards(deckID) {
                switch $0 {
                case .Success(let flashcards):
                    for flashcard in flashcards {
                        dispatch_group_enter(group)
                        
                        self.dataManager.allTipsForFlashcard(deckID, flashcardID: flashcard.serverID) {
                            switch $0 {
                            case .Success(_):
                                break
                            case .Error(let tipErr):
                                debugPrint(tipErr)
                                completion(.Failure)
                            }
                            dispatch_group_leave(group)
                        }
                    }
                case .Error(let deckErr):
                    debugPrint(deckErr)
                    completion(.Failure)
                }
                dispatch_group_leave(group)
            }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            completion(.Success)
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
