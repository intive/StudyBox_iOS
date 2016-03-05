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
    
    func getDecks(sorted:Bool )->[Deck] {
        if (sorted){
            return decks.sort {
                $0.name > $1.name
            }
        }
        
        return decks;
    }
    
    func getDeck(byId id:String)->Deck? {
        return decks.findUniqe(withId: id)
        
    }
    
    func updateDeck(data:Deck)throws {
        if let index = decks.indexOfUnique(data.id){
            decks[index] = data
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
    func removeDeck(data:Deck)throws {
        return try removeDeck(withId: data.id)
    }
    
    
    func getFlashcard(byId id:String)->Flashcard? {
        return flashcards.findUniqe(withId: id)
    }
    
    
    func getFlashcards(forDeckWithId id:String) throws ->[Flashcard] {
        
        if let deck = decks.findUniqe(withId: id){
            return flashcards.filter {
                $0.deckId == deck.id
            }
        }else {
            throw DataManagerError.NoDeckWithGivenId
        }
        
    }
    
    func getFlashcards(forDeck deck:Deck)throws ->[Flashcard] {
        return try getFlashcards(forDeckWithId: deck.id)
        
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
    
    
    
}
