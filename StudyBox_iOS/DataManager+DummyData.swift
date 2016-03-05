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
        "Swift","Obj-C","Very long name of the deck, so I can remember everything for a very long time : ) ", "Math","Physics","English", "Even longer name of the deck, so I can remember everything for at least double as long. No need to study something twice sounds very promising, hope it will really work. I will try hard!"
    ]

    static func managerWithDummyData()->DataManager {
        let manager = DataManager()
        DataManager.DummyDecks.forEach { name in
            let id = manager.addDeck(name)
            
            
            let question = "\(name) question"
            let answer = "\(name) answer"
            
            var tip:Tip?
            
            
            for i in 0...6 {
                let iStr = "\(i)"
                if ( i % 2  == 0){
                    tip = Tip.Text(text: "\(name) tip")
                }else {
                    tip = nil
                }
                
                try! manager.addFlashcard(forDeckWithId: id, question: question + iStr, answer: answer + iStr, tip: tip)

                
            }
            
        }
        
        return manager 
    }
}
