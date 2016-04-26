//
//  WatchManager.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 22.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import WatchKit
import WatchConnectivity
import RealmSwift

class WatchManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = WatchManager()

    private let session: WCSession = WCSession.defaultSession()
    
    func startSession() {
        session.delegate = self
        session.activateSession()
    }
    
    //Return format: [(Question,Answer,Tip)]
    func getDataFromRealm() -> [(String,String,String)] {
        var storedFlashcards = [(String,String,String)]()
        if let realm = try? Realm() {
            let flashcardsFromRealm = realm.objects(WatchFlashcard).toArray()
            for i in 0..<flashcardsFromRealm.count {
                storedFlashcards.append((flashcardsFromRealm[i].question, flashcardsFromRealm[i].answer, flashcardsFromRealm[i].tip))
            }
        }
        return storedFlashcards
    }
    
    func overwriteDataInRealm(applicationContext: [String : AnyObject]) {
        var storedFlashcards = [WatchFlashcard]()
        
        if let realm = try? Realm() {
            do {
                try realm.write() {
                    if let flashcardsQ = applicationContext["flashcardsQuestions"] as? [String],
                        let flashcardsA = applicationContext["flashcardsAnswers"] as? [String],
                        let flashcardIDs = applicationContext["flashcardsIDs"] as? [String],
                        let flashcardsTips = applicationContext["flashcardsTips"] as? [String] {
                        for i in 0..<flashcardsQ.count {
                            storedFlashcards.append(WatchFlashcard(serverID: flashcardIDs[i], question: flashcardsQ[i], answer: flashcardsA[i], tip: flashcardsTips[i]))
                        }
                        realm.deleteAll()
                        realm.add(storedFlashcards)
                    }
                }
            } catch let e {
                debugPrint(e)
            }
        }
    }
}

extension WatchManager {
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if !applicationContext.isEmpty {
            overwriteDataInRealm(applicationContext)
        }
    }
}
