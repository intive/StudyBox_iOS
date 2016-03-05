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
    
    
    func downloadDecks()->[Deck]? {
        //TODO wait for backend
        return nil 
    }
    
    func getDeck(byId id:String)->Deck? {
        let unique:Deck? = decks.findUniqe(withId: id)
        return unique
        
    }
    
    func updateDeck(data:Deck)throws {
        
        if let index = decks.indexOf(data) {
            decks[index] = data
        }else {
            throw DataManagerError.NoDeckWithGivenId
        }
        
    }
    
    func addDeck(name:String)->String {
        
        var validId = false
        var id = ""
        while(!validId){
            id = randomId()
            
            validId = !Bool(decks.filter( { $0.id == id }).count)
        }
        
        decks.append(Deck(id: id, name: name))
        
        return id
    }
    
    func removeDeck(data:Deck)throws {
        if let index = decks.indexOf(data){
            
            flashcards = flashcards.filter {
                $0.deckId != data.id
            }
            
            decks.removeAtIndex(index)
        }else {
            throw DataManagerError.NoDeckWithGivenId
        }
    }
    
    
    func downloadFlashcards()->[Flashcard]? {
        //TODO wait for backend 
        return nil
    }
    
    func getFlashcard(byId id:String)->Flashcard? {
        let unique:Flashcard? = flashcards.findUniqe(withId: id)
        return unique
    }
    
    
    func getFlashcards(forDeckWithId id:String) throws ->[Flashcard] {
        
        if (decks.findUniqe(withId: id) == nil){
            throw DataManagerError.NoDeckWithGivenId
        }
        let result = flashcards.filter {
            $0.deckId == id
        }
        
        return result
    }
    
    func getFlashcards(forDeck deck:Deck)throws ->[Flashcard] {
        if let result = try? getFlashcards(forDeckWithId: deck.id){
            return result
        }
        throw DataManagerError.NoDeckWithGivenId
    }
    
    func updateFlashcard(data:Flashcard)throws {
        if let index = flashcards.indexOf(data){
            flashcards[index] = data
        }else {
            throw DataManagerError.NoFlashcardWithGivenId
        }
    }
    
    func addFlashcard(forDeckWithId deckId:String, question:String,answer:String,tip:Tip?)throws -> String  {
        
        if (decks.findUniqe(withId: deckId) == nil){
            throw DataManagerError.NoDeckWithGivenId
        }
        
        var validId = false
        var flashcardId = ""
        while(!validId){
            flashcardId = randomId()
            
            validId = !Bool(flashcards.filter( { $0.id == flashcardId }).count)
        }
        
        flashcards.append(Flashcard(id: flashcardId, deckId: deckId, question: question, answer: answer, tip: tip))
        return flashcardId
    }
    
    func addFlashcard(forDeck deck:Deck, question:String,answer:String,tip:Tip?)throws -> String  {
        
        if let resultId = try? addFlashcard(forDeckWithId: deck.id, question: question, answer: answer, tip: tip){
            return resultId
        }
        throw DataManagerError.NoDeckWithGivenId
    }
    
    
    func removeFlashcard(data:Flashcard)throws{
        if let index = flashcards.indexOf(data){
            flashcards.removeAtIndex(index)
        }else {
            throw DataManagerError.NoFlashcardWithGivenId
        }
        
    }
    
    
    func randomId()->String {
        var i = 0;
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".characters
        let length = UInt32(letters.count)
        
        var random = String()
        while (i < 32){
            let rand = Int(arc4random_uniform(length))
            
            random.append(letters[letters.startIndex.advancedBy(rand)])
            i = i + 1;
        }
        return random
    }
    
    
}
