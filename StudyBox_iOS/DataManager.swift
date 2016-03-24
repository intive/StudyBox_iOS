//
//  DataManager.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import RealmSwift

enum DataManagerError:ErrorType {
    case NoDeckWithGivenId, NoFlashcardWithGivenId
}

/**
 Class responisble for handling data model stored in memory
*/
class DataManager {
    
    private var decks = [Deck]()
    // private var flashcards = [Flashcard]()
    private let realm = try! Realm()
    
    init(){
        // usuwanie tylko wtedy gdy jest internet i najpewniej nie w tym miejscu. Na razie ze względu na 
        // DummyData
        // TODO: relocate deleteAll() and check for internet connection
        try! realm.write {
            realm.deleteAll()
        }
        // adding notification, with this decks are going to be loaded again, when database changed
        _ = realm.addNotificationBlock { notification, realm in
            if !self.decks.isEmpty {
                self.decks.removeAll()
            }
        }
    }
    
    func decks(sorted:Bool )->[Deck] {
        // load all Deck from database to memory, if not loaded
        if decks.isEmpty {
            decks = realm.objects(Deck).toArray()
        }
        
        if (sorted){
            return decks.sort {
                $0.name < $1.name
            }
        }
        return decks;
    }
    
    func deck(withId id:String)->Deck? {
        
        let selectedDeck = realm.objects(Deck).filter("_id == '\(id)'").first

        return selectedDeck
    }
    
    func updateDeck(deck:Deck)throws {
        
        let selectedDeck = realm.objects(Deck).filter("_id == '\(deck.id)'").first
        if let updatingDeck = selectedDeck{
            try! realm.write {
                updatingDeck.name = deck.name
            }
        }else {
            DataManagerError.NoDeckWithGivenId
        }
        
    }
    
    func addDeck(name:String)->String {

        let id = decks.generateNewId()
        let newDeck = Deck(id: id, name: name)
        
        
        try! realm.write {
            realm.add(newDeck)
        }
        
        return id
    }

    func removeDeck(withId id:String) throws {
        
        let selectedDeck = realm.objects(Deck).filter("_id == '\(id)'").first
        if let deck = selectedDeck {
            
            let toRemove = deck.flashcards
            try! realm.write {
                realm.delete(toRemove)
                realm.delete(deck)
            }
            
        }else {
            throw DataManagerError.NoDeckWithGivenId
        }
    }
    
    func removeDeck(deck:Deck)throws {
        return try removeDeck(withId: deck.id)
    }
    
    
    func flashcard(withId id:String)throws ->Flashcard? {
        
        let selectedFlashcard = realm.objects(Flashcard).filter("_id == '\(id)'").first
        if let flashcard = selectedFlashcard{
            return flashcard
        } else {
            throw DataManagerError.NoFlashcardWithGivenId
        }
    }
    
    
    func flashcards(forDeckWithId deckId:String) throws ->[Flashcard] {
        
        let selectedDeck = realm.objects(Deck).filter("_id == '\(deckId)'").first
        if let deck = selectedDeck {
            return deck.flashcards
        }else {
            throw DataManagerError.NoDeckWithGivenId
        }
        
    }
    
    
    func flashcards(forDeck deck:Deck)throws ->[Flashcard] {
        return try flashcards(forDeckWithId: deck.id)
        
    }

    func updateFlashcard(data:Flashcard)throws {
        
        let selectedFlashcard = realm.objects(Flashcard).filter("_id == '\(data.id)'").first
        if let flashcard = selectedFlashcard {
            try! realm.write {
                flashcard.question = data.question
                flashcard.answer = data.answer
                flashcard.tip = data.tip
                flashcard.hidden = data.hidden
                flashcard.deck = data.deck
            }
        }else {
            throw DataManagerError.NoFlashcardWithGivenId
        }
    }
    
    func addFlashcard(forDeckWithId deckId:String, question:String,answer:String,tip:Tip?)throws -> String  {
        
        let selectedDeck = realm.objects(Deck).filter("_id == '\(deckId)'").first
        if (selectedDeck == nil){
            throw DataManagerError.NoDeckWithGivenId
        }
        
        let flashcardId = NSUUID().UUIDString
        let newFlashcard = Flashcard(id: flashcardId, deckId: deckId, question: question, answer: answer, tip: tip)
        
        newFlashcard.deck = selectedDeck
        
        try! realm.write {
            realm.add(newFlashcard)
        }
        
        return flashcardId
    }
    
    func addFlashcard(forDeck deck:Deck, question:String,answer:String,tip:Tip?)throws -> String  {
        
        return try addFlashcard(forDeckWithId: deck.id, question: question, answer: answer, tip: tip)
        
    }
    
    func removeFlashcard(withId id:String)throws {
        
        let selectedFlashcard = realm.objects(Flashcard).filter("_id == '\(id)'").first
        if let flashcardToremove = selectedFlashcard {
            try! realm.write {
                realm.delete(flashcardToremove)
            }
        }else {
            throw DataManagerError.NoFlashcardWithGivenId
        }
    }
    
    func removeFlashcard(data:Flashcard)throws {
        return try removeFlashcard(withId: data.id)
    }
    
    func hideFlashcard(withId id:String)throws {
        
        let selectedFlashcard = realm.objects(Flashcard).filter("_id == '\(id)'").first
        if let flashcardToUnHide = selectedFlashcard {

            try! realm.write {
                flashcardToUnHide.hidden = true
            }
        } else {
            throw DataManagerError.NoFlashcardWithGivenId
        }
    }
    
    func unhideFlashcard(withId id:String)throws {
        
        let selectedFlashcard = realm.objects(Flashcard).filter("_id == '\(id)'").first
        if let flashcardToHide = selectedFlashcard {
            
            try! realm.write {
                flashcardToHide.hidden = false
            }
        } else {
            throw DataManagerError.NoFlashcardWithGivenId
        }
    }
    
}
