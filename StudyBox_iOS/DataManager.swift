//
//  DataManager.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation


enum DataManagerError:ErrorType {
    case NoDeckWithGivenId, NoFlashcardWithGivenId
}

/**
 Class responisble for handling data model stored in memory
*/
class DataManager {
    
    private var decks = [Deck]()
    private var flashcards = [Flashcard]()
    
    func decks(sorted:Bool )->[Deck] {
        if (sorted){
            return decks.sort {
                $0.name < $1.name
            }
        }
        return decks;
    }
    
    func deck(withId id:String)->Deck? {
        return decks.findUniqe(withId: id)
        
    }
    
    func updateDeck(deck:Deck)throws {
        if let index = decks.indexOfUnique(deck.id){
            decks[index] = deck
        }else {
            DataManagerError.NoDeckWithGivenId
        }
        
    }
    
    func addDeck(name:String)->String {
        
        let id = decks.generateNewId()
        decks.append(Deck(id: id, name: name))
        
        return id
    }
    
    func removeDeck(withId id:String) throws {
        if let index = decks.indexOfUnique(id){
            
            flashcards = flashcards.filter {
                $0.deckId != id
            }
            
            decks.removeAtIndex(index)
        }else {
            throw DataManagerError.NoDeckWithGivenId
        }
    }
    
    func removeDeck(deck:Deck)throws {
        return try removeDeck(withId: deck.id)
    }
    
    
    func flashcard(withId id:String)->Flashcard? {
        return flashcards.findUniqe(withId: id)
    }
    
    
    func flashcards(forDeckWithId deckId:String) throws ->[Flashcard] {
        
        if let deck = decks.findUniqe(withId: deckId){
            return flashcards.filter {
                $0.deckId == deck.id
            }
        }else {
            throw DataManagerError.NoDeckWithGivenId
        }
        
    }
    
    
    func flashcards(forDeck deck:Deck)throws ->[Flashcard] {
        return try flashcards(forDeckWithId: deck.id)
        
    }
    
    func updateFlashcard(data:Flashcard)throws {
        if let index = flashcards.indexOfUnique(data.id){
            flashcards[index] = data
        }else {
            throw DataManagerError.NoFlashcardWithGivenId
        }
    }
    
    func addFlashcard(forDeckWithId deckId:String, question:String,answer:String,tip:Tip?)throws -> String  {
        
        if (decks.findUniqe(withId: deckId) == nil){
            throw DataManagerError.NoDeckWithGivenId
        }
        
        let flashcardId = flashcards.generateNewId()
        
        flashcards.append(Flashcard(id: flashcardId, deckId: deckId, question: question, answer: answer, tip: tip))
        return flashcardId
    }
    
    func addFlashcard(forDeck deck:Deck, question:String,answer:String,tip:Tip?)throws -> String  {
        
        return try addFlashcard(forDeckWithId: deck.id, question: question, answer: answer, tip: tip)
        
    }
    
    func removeFlashcard(withId id:String)throws {
        if let index = flashcards.indexOfUnique(id){
            flashcards.removeAtIndex(index)
        }else {
            throw DataManagerError.NoFlashcardWithGivenId
        }
    }
    
    func removeFlashcard(data:Flashcard)throws {
        return try removeFlashcard(withId: data.id)
    }
    
    func hideFlashcard(withId id:String)throws {
        if let index = flashcards.indexOfUnique(id) {
                flashcards[index].hidden = true
            } else {
                throw DataManagerError.NoFlashcardWithGivenId
            }
        }
    
    func unhideFlashcard(withId id:String)throws {
        if let index = flashcards.indexOfUnique(id) {
                flashcards[index].hidden = false
            } else {
                throw DataManagerError.NoFlashcardWithGivenId
            }
        }
    
    
}
