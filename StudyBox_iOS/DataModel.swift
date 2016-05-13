//
//  File.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

protocol UniquelyIdentifiable {
    var serverID: String { get }
}

class Tip: Object, UniquelyIdentifiable, JSONInitializable {
    
    dynamic private(set) var serverID: String = ""
    dynamic var flashcardID: String = ""
    dynamic var deckID: String = ""
    dynamic var essence: String = ""
    dynamic var difficult: Int = 0
    
    required convenience init?(withJSON json: JSON) {
        if let jsonDict = json.dictionary {
            if let id = jsonDict["id"]?.string, essence = jsonDict["essence"]?.string, difficult = jsonDict["difficult"]?.int {
                self.init(deckID: "", flashcardID: "", serverID: id, essence: essence, difficult: difficult)
                return
            }
        }
        return nil
    }
    
    convenience init(deckID: String, flashcardID: String, serverID: String, essence: String, difficult: Int){
        self.init()
        self.serverID = serverID
        self.deckID = deckID
        self.flashcardID = flashcardID
        self.essence = essence
        self.difficult = difficult
    }
    
    override class func primaryKey() -> String? {
        return "serverID"
    }
    
    func addParentFlashcard(flashcardID: String, deckID: String) {
        self.deckID = deckID
        self.flashcardID = flashcardID
    }
}

class Flashcard: Object, UniquelyIdentifiable, JSONInitializable {
    dynamic private(set) var serverID: String = NSUUID().UUIDString
    dynamic private(set) var deckId: String = ""
    dynamic var deck: Deck?
    dynamic var question: String = ""
    dynamic var answer: String = ""
    dynamic var hidden: Bool = false
    
    required convenience init?(withJSON json: JSON) {
        if let jsonDict = json.dictionary {
            if let id = jsonDict["id"]?.string, deckId = jsonDict["deckId"]?.string, question = jsonDict["question"]?.string,
                answer = jsonDict["answer"]?.string, isHidden = jsonDict["isHidden"]?.bool {
                self.init(serverID: id, deckId: deckId, question: question, answer: answer, isHidden: isHidden)
                return
            }
        }
        return nil
    }
    
    override class func primaryKey() -> String? {
        return "serverID"
    }
    
    convenience init(serverID: String, deckId: String, question: String, answer: String, isHidden: Bool = false){
        self.init()
        self.serverID = serverID
        self.deckId = deckId
        self.question = question
        self.answer = answer
        self.hidden = isHidden
    }
}


class Deck: Object, UniquelyIdentifiable, Searchable, JSONInitializable {
    
    dynamic private(set) var serverID: String = NSUUID().UUIDString
    dynamic var name: String = ""
    dynamic var isPublic: Bool = true

    var flashcards: [Flashcard] {
        return linkingObjects(Flashcard.self, forProperty: "deck")
    }
    
    required convenience init?(withJSON json: JSON) {
        if let jsonDict = json.dictionary {
            if let id = jsonDict["id"]?.string, name = jsonDict["name"]?.string, isPublic  = jsonDict["isPublic"]?.bool {
                self.init(serverID: id, name: name, isPublic: isPublic)
                return 
            }
        }
        return nil
    }
    
    override class func primaryKey() -> String? {
        return "serverID"
    }
    
    convenience init(serverID: String, name: String, isPublic: Bool = true){
        self.init()
        self.serverID = serverID
        self.name = name
        self.isPublic = isPublic
    }
    
    func matches(expression: String?) -> Bool {
        let noTitle = Utils.DeckViewLayout.DeckWithoutTitle.lowercaseString
        if let text = expression?.lowercaseString {
            if name.characters.isEmpty {
                return noTitle.containsString(text)
            }
            return name.lowercaseString.containsString(text)
        }
        return name == ""
    }
    
}


func == (lhs: Deck, rhs: Deck) -> Bool {
    return lhs.serverID == rhs.serverID && lhs.name == rhs.name
}

func == (lhs: Flashcard, rhs: Flashcard) -> Bool {
    return lhs.serverID == rhs.serverID && lhs.deckId == rhs.deckId && lhs.question == rhs.question && lhs.answer == rhs.answer
}


func == (lhs: Tip, rhs: Tip) -> Bool {
    return lhs.serverID == rhs.serverID
}
