//
//  File.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

protocol UniquelyIdentifiable {
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

struct Flashcard:Equatable,UniquelyIdentifiable {
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
    var hidden:Bool

    init(id:String,deckId:String,question:String,answer:String,tip:Tip?){
        _id = id
        self._deckId = deckId
        self.question = question
        self.answer = answer
        self.tip = tip
        self.hidden = false
    }
    
}

struct Deck:Equatable,UniquelyIdentifiable {
    
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
    
}


func ==(lhs:Deck,rhs:Deck)->Bool {
    return lhs.id == rhs.id && lhs.name == rhs.name
}

func ==(lhs:Flashcard,rhs:Flashcard)->Bool {
    return lhs.id == rhs.id && lhs.deckId == rhs.deckId && lhs.question == rhs.question && lhs.answer == rhs.answer && lhs.tip == rhs.tip
}


func ==(lhs:Tip,rhs:Tip)->Bool {
    return lhs.description == rhs.description
}
