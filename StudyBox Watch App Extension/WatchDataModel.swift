//
//  WatchDataModel.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 24.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import RealmSwift

class WatchFlashcard: Object {
    dynamic private(set) var serverID: String = NSUUID().UUIDString
    dynamic var question: String = ""
    dynamic var answer: String = ""
    dynamic var tip: String? = nil
    
    convenience init(serverID: String, question: String, answer: String, tip: String?){
        self.init()
        self.serverID = serverID
        self.question = question
        self.answer = answer
        self.tip = tip
    }
}
