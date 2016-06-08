//
//  WatchDataModel.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 24.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import RealmSwift

class WatchFlashcard: Object {
    dynamic private(set) var serverID: String = ""
    dynamic var question: String = ""
    dynamic var answer: String = ""
    var tips = List<WatchTip>()
    
    convenience init(serverID: String, question: String, answer: String, tips: List<WatchTip>){
        self.init()
        self.serverID = serverID
        self.question = question
        self.answer = answer
        self.tips = tips
    }
}

class WatchTip: Object {
    dynamic var content: String = ""

    convenience init(content: String){
        self.init()
        self.content = content
    }
}
