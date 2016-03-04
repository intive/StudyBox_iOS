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
        "Swift","Obj-C","Math","Physics","English"
    ]

    static func managerWithDummyData()->DataManager {
        let manager = DataManager()
        DataManager.DummyDecks.forEach {
            let id = manager.addDeck($0)
            
            
            let question = "\($0) question"
            let answer = "\($0) answer"
            
            let tip = Tip.Text(text: "\($0) tip")
            print(tip)
            for i in 0...3 {
                let iStr = "\(i)"
                
                try! manager.addFlashcard(forDeckWithId: id, question: question + iStr, answer: answer + iStr, tip: tip)
            }
            
        }
        
        return manager 
    }
}
