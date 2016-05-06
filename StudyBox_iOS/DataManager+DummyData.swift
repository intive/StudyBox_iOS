//
//  DataManager+DummyData.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension DataManager {
    static let DummyDecks = [
        "Swift", "Obj-C", "Stół z powyłamywanymi nogami",
        "Math", "Physics", "English", "Sample of\nmultiline\nvery\nvery\nvery\nlong\ndeck\nname",
        "Even longer name of the deck, so I can remember everything for at least double as long.",
        "No need to study something twice sounds very promising, hope it will really work. I will try hard!", "",
        "Sh", "StudyBox是伟大的！"
    ]

    static func managerWithDummyData() -> DataManager {
        let manager = DataManager()
        
        if manager.decks(false).isEmpty {
            DataManager.DummyDecks.forEach { name in
                let id = manager.addDeck(name)
                //We create random number of 0 to 30 flashcards, different for each deck
                let limit = arc4random_uniform(UInt32(29)) + 1
                var tip: Tip?
                var cardId: String
                var countToHide: Int = 0
                
                for i in 0...limit {
                    let rand = arc4random_uniform(UInt32(100)) //Random number to append in each flashcard
                    let question = "\(name) question \(rand)"
                    let answer = "\(name) answer \(rand)"
                    if i % 2  == 0 {
                        tip = Tip.Text(text: "\(name) tip \(rand)")
                    } else {
                        tip = nil
                    }
                    do {
                        try cardId = manager.addFlashcard(forDeckWithId: id, question: question, answer: answer, tip: tip)
                        countToHide += 1
                        
                        //Hides every 3rd generated flashcard
                        if countToHide % 3 == 0 {
                            do {
                                try manager.hideFlashcard(withId: cardId)
                            } catch let e {
                                debugPrint(e)
                            }
                        }
                    } catch let e {
                        debugPrint(e)
                    }
                }
            }
        }
        return manager 
    }
}
