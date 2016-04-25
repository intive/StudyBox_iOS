//
//  File.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
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

class Flashcard: Object, Equatable, UniquelyIdentifiable {
    dynamic private(set) var serverID: String = NSUUID().UUIDString
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
    
    convenience init(serverID: String, deckId: String, question: String, answer: String, tip: Tip?){
        self.init()
        self.serverID = serverID
        self.deckId = deckId
        self.question = question
        self.answer = answer
        self.tipEnum = tip
        self.hidden = false
    }
}

class Deck: Object, Equatable, UniquelyIdentifiable, Searchable {
    
    dynamic private(set) var serverID: String = NSUUID().UUIDString
    dynamic var name: String = ""

    var flashcards: [Flashcard] {
        return linkingObjects(Flashcard.self, forProperty: "deck")
    }
    
    convenience init(serverID: String, name: String){
        self.init()
        self.serverID = serverID
        self.name = name
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
