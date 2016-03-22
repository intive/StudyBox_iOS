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
        "Swift","Obj-C","Very long name of the deck, so I can remember everything for a very long time : ) ",
        "Math","Physics","English","Just a decent length name \nhere",
        "Even longer name of the deck, so I can remember everything for at least double as long. \n" +
        "No need to study something twice sounds very promising, hope it will really work. I will try hard!",
        "","Sh"
    ]

    static func managerWithDummyData()->DataManager {
        let manager = DataManager()
        let size = DataManager.DummyDecks.count
        let limit = size - 1
        DataManager.DummyDecks.forEach { name in
            let id = manager.addDeck(name)
            
            
            var question = "\(name) question"
            var answer = "\(name) answer"
            
            var tip:Tip?
            var cardId:String //Helps in hiding
            var countToHide:Int = 0 //Helps in hiding too
            
            for i in 0...limit {
                let clear = (i == limit || i == limit - 1 || i == limit / 2 || i == limit / 2 - 1)
                if ( i % 2  == 0){
                    tip = Tip.Text(text: "\(name) tip")
                    let choice = Int(arc4random_uniform(UInt32(size)))
                    
                    question.appendContentsOf("\n \(DataManager.DummyDecks[choice])")
                    answer.appendContentsOf("\n \(DataManager.DummyDecks[choice])")
                    if (clear) {
                        answer = ""
                    }

                }else {
                    if (clear) {
                        question = ""
                    }
                    tip = nil
                }
                
                try! cardId = manager.addFlashcard(forDeckWithId: id, question: question, answer: answer, tip: tip)
                countToHide++
                
                //Hides every 3th generated flashcard
                if (countToHide % 3 == 0) {
                    try! manager.hideFlashcard(withId: cardId)
                }

                
            }
            
        }
        
        return manager 
    }
}
