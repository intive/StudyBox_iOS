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

enum Tip: CustomStringConvertible, Equatable  {
    case Text(text:String)
    
    var description: String {
        get {
            switch self {
            case .Text(let text):
                return text
            }
        }
    }
}

class Flashcard: Object, UniquelyIdentifiable, JSONInitializable, LocalParentStoreable {
    dynamic private(set) var serverID: String = ""
    dynamic private(set) var deckId: String = ""
    dynamic var deck: Deck?
    dynamic var question: String = ""
    dynamic var answer: String = ""
    dynamic var tip = Tip.Text(text: "").description
    var tipEnum: Tip? {
        get {
            return Tip.Text(text: tip)
        }
        set {
            if let value = newValue {
                tip = value.description
            }
        }
    }
    dynamic var hidden: Bool = false
    
    required convenience init?(withJSON json: JSON) {
        if let jsonDict = json.dictionary {
            if let id = jsonDict["id"]?.string, deckId = jsonDict["deckId"]?.string, question = jsonDict["question"]?.string,
                answer = jsonDict["answer"]?.string, isHidden = jsonDict["isHidden"]?.bool {
                self.init(serverID: id, deckID: deckId, question: question, answer: answer, tip: nil, isHidden: isHidden)
                return
            }
        }
        return nil
    }
    
    override class func primaryKey() -> String? {
        return "serverID"
    }
    
    convenience init(serverID: String, deckID: String, question: String, answer: String, tip: Tip?, isHidden: Bool = false){
        self.init()
        self.serverID = serverID
        self.deckId = deckID
        self.question = question
        self.answer = answer
        self.tipEnum = tip
        self.hidden = isHidden
    }
    convenience init(deckID: String, question: String, answer: String, tip: Tip?, isHidden: Bool = false) {
        self.init(serverID: "", deckID: deckID, question: question, answer: answer, tip: tip, isHidden: isHidden)
    }
    
    func storeLocalParent(localDataManager: LocalDataManager) {
        self.deck = localDataManager.get(Deck.self, withId: deckId)
    }
    
    
}


class Deck: Object, UniquelyIdentifiable, Searchable, JSONInitializable {
    
    dynamic private(set) var serverID: String = ""
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
    
    convenience init(serverID: String, name: String, isPublic: Bool = true ){
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


func == (lhs: Deck, rhs: Deck) -> Bool {
    return lhs.serverID == rhs.serverID && lhs.name == rhs.name
}

func == (lhs: Flashcard, rhs: Flashcard) -> Bool {
    return lhs.serverID == rhs.serverID && lhs.deckId == rhs.deckId && lhs.question == rhs.question && lhs.answer == rhs.answer && lhs.tip == rhs.tip
}


func == (lhs: Tip, rhs: Tip) -> Bool {
    return lhs.description == rhs.description
}
