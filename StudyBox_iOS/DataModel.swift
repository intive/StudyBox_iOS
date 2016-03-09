//
//  File.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

protocol UniqueModelId {
    var id:String {get }
}

enum Tip:CustomStringConvertible,Equatable  {
    case Text(text:String)
    
    var description:String {
        get {
            switch self {
            case .Text(let text):
                return text
            }
        }
    }
    
}

/**
 Flashcards are equall if their IDs are, use `equals` method to compare their contents and IDs
*/
struct Flashcard:Equatable,UniqueModelId {
    private var _id:String
    var id:String  {
        get {
            return self._id
        }
    }
    
    private var _deckId:String
    var deckId:String {
        get {
            return self._deckId;
        }
    }
    
    var question:String
    var answer:String
    var tip:Tip?
    
    init(id:String,deckId:String,question:String,answer:String,tip:Tip?){
        _id = id
        self._deckId = deckId
        self.question = question
        self.answer = answer
        self.tip = tip
    }
    
    func equals(another:Flashcard)->Bool {
        return id == another.id && deckId == another.deckId && question == another.question && answer == another.answer && tip == another.tip
    }
}

/**
 Decks are equall if their IDs are, use `equals` method to compare their contents and IDs
 */
struct Deck:Equatable,UniqueModelId {
    
    private var _id:String
    var id:String {
        get {
            return self._id;
        }
    }
    var name:String
    
    init(id:String,name:String){
        self._id = id
        self.name = name
    }
    
    func equals(another:Deck)->Bool {
        return id == another.id && name == another.name
    }
    
}


func ==(lhs:Deck,rhs:Deck)->Bool {
    return lhs.id == rhs.id 
}

func ==(lhs:Flashcard,rhs:Flashcard)->Bool {
    return lhs.id == rhs.id 
}


func ==(lhs:Tip,rhs:Tip)->Bool {
    return lhs.description == rhs.description
}
