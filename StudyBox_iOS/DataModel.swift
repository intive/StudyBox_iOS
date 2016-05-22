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
    dynamic var content: String = ""
    dynamic var difficulty: Int = 0
    
    required convenience init?(withJSON json: JSON) {
        if let jsonDict = json.dictionary {
            if let id = jsonDict["id"]?.string, essence = jsonDict["essence"]?.string, difficult = jsonDict["difficult"]?.int {
                self.init(deckID: "", flashcardID: "", serverID: id, content: essence, difficulty: difficult)
                return
            }
        }
        return nil
    }
    
    convenience init(deckID: String, flashcardID: String, serverID: String, content: String, difficulty: Int){
        self.init()
        self.serverID = serverID
        self.deckID = deckID
        self.flashcardID = flashcardID
        self.content = content
        self.difficulty = difficulty
    }
    
    override class func primaryKey() -> String? {
        return "serverID"
    }
    
    func addParentFlashcard(flashcardID: String, deckID: String) {
        self.deckID = deckID
        self.flashcardID = flashcardID
    }
}

class Flashcard: Object, UniquelyIdentifiable, JSONInitializable  {
    dynamic private(set) var serverID: String = ""
    dynamic private(set) var deckId: String = ""
    dynamic var deck: Deck? {
        return realm?.objectForPrimaryKey(Deck.self, key: serverID)
    }
    dynamic var question: String = ""
    dynamic var answer: String = ""
    dynamic var hidden: Bool = false
    
    required convenience init?(withJSON json: JSON) {
        if let jsonDict = json.dictionary {
            if let id = jsonDict["id"]?.string, deckId = jsonDict["deckId"]?.string, question = jsonDict["question"]?.string,
                answer = jsonDict["answer"]?.string, isHidden = jsonDict["isHidden"]?.bool {
                self.init(serverID: id, deckID: deckId, question: question, answer: answer, isHidden: isHidden)
                return
            }
        }
        return nil
    }
    
    override class func primaryKey() -> String? {
        return "serverID"
    }
    
    convenience init(serverID: String, deckID: String, question: String, answer: String, isHidden: Bool = false){
        self.init()
        self.serverID = serverID
        self.deckId = deckID
        self.question = question
        self.answer = answer
        self.hidden = isHidden
    }
    convenience init(deckID: String, question: String, answer: String, isHidden: Bool = false) {
        self.init(serverID: "", deckID: deckID, question: question, answer: answer, isHidden: isHidden)
    }
    
}


class Deck: Object, UniquelyIdentifiable, Searchable, JSONInitializable {
    
    dynamic private(set) var serverID: String = ""
    dynamic var name: String = ""
    dynamic var isPublic: Bool = true
    dynamic var owner: String = ""
    dynamic var createDate: NSDate?

    var flashcards: [Flashcard] {
        return realm?.objects(Flashcard).filter("deckId == '\(serverID)'").map { $0 } ?? []
    }
    
    required convenience init?(withJSON json: JSON) {
        if let jsonDict = json.dictionary {
            if let id = jsonDict["id"]?.string, name = jsonDict["name"]?.string, isPublic  = jsonDict["isPublic"]?.bool {
                self.init(serverID: id, name: name, isPublic: isPublic)
                if let owner = jsonDict["creatorEmail"]?.string {
                    self.owner = owner
                }
                if let date = jsonDict["creationDate"]?.string {
                    let formatter = NSDateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SS"
                    self.createDate = formatter.dateFromString(date)
                }
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
        self.name = name
        self.serverID = serverID
        self.isPublic = isPublic
    }
    
    convenience init(name: String, isPublic: Bool = true ){
        self.init(serverID: "", name: name, isPublic: isPublic)
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

class TestInfo: Object {
    dynamic var deck: Deck!
    dynamic var answeredFlashcardsCount: Int = 0
    dynamic var correctlyAnsweredFlashcardsCount: Int = 0
    dynamic var localID = NSUUID().UUIDString
    
    override class func primaryKey() -> String? {
        return "localID"
    }
    
    convenience init(deck: Deck, answeredFlashcardsCount: Int, correctlyAnsweredFlashcardsCount: Int) {
        self.init()
        self.deck = deck
        self.answeredFlashcardsCount = answeredFlashcardsCount
        self.correctlyAnsweredFlashcardsCount = correctlyAnsweredFlashcardsCount
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
