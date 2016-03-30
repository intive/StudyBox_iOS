//
//  DataManager.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON

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
    // dzięki deckDBChanged talie będą wczytywane z bazy tylko w przypadku zmiany tabeli Deck
    // !!! Zmiana tabeli Flashcard nie jest brana pod uwagę
    private var deckDBChanged: Bool = true
    
    init(){
        
        // usuwanie tylko wtedy gdy jest internet i najpewniej nie w tym miejscu. Na razie ze względu na 
        // DummyData
        // TODO: relocate removeDecksFromDatabase() and check for internet connection
        removeDecksFromDatabase()
    }
    
    func getDecksFromServer(){
        Alamofire.request(.GET, "https://private-anon-595007b68-studybox.apiary-mock.com/decks")
            .responseJSON { response in
            
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        
                        let json = JSON(value)
                        for (_, subJson) in json {
                            
                            let newDeck = Deck(id: subJson["id"].stringValue, name: subJson["name"].stringValue)
                            
                            let selectedDeck = self.realm.objects(Deck).filter("_id == '\(newDeck.id)'").first
                            if let updatingDeck = selectedDeck{
                                try! self.realm.write {
                                    updatingDeck.name = newDeck.name
                                }
                                
                            }else {
                                try! self.realm.write {
                                    self.realm.add(newDeck)
                                }
                            }
                        }
                        self.deckDBChanged = true
                    }
                case .Failure(let error):
                   print("Request failed with error: \(error)")
                    
                }
        }
    }
    
    func decks(sorted:Bool )->[Deck] {
        
        // wczytuje talie jeśli nastąpiła zmiana w tabeli talii w bazie lub puste
        if deckDBChanged || decks.isEmpty {
            loadDecksFromDatabase()
        }

        if (sorted){
            return decks.sort {
                $0.name < $1.name
            }
        }
        return decks.copy()
    }
    
    // loading decks from Realm. Used for refresh after changing decks in db
    func loadDecksFromDatabase(forced: Bool = false) {
        
        if !decks.isEmpty || forced{
            decks.removeAll()
        }
        
        decks = realm.objects(Deck).toArray()
        // jako że załadowane talie z pamięci zgadzają się z tymi z bazy, to false
        deckDBChanged = false
    }
    
    func removeDecksFromDatabase() {
        try! realm.write {
            realm.deleteAll()
        }
        
        deckDBChanged = true
        
    }
    
    func deck(withId id:String)->Deck? {
        
        let selectedDeck = realm.objects(Deck).filter("_id == '\(id)'").first
        if let deck = selectedDeck {
            return deck.copy() as? Deck
        } else {
            return nil
        }

    }
    
    func updateDeck(deck:Deck)throws {
        
        let selectedDeck = realm.objects(Deck).filter("_id == '\(deck.id)'").first
        if let updatingDeck = selectedDeck{
            try! realm.write {
                updatingDeck.name = deck.name
            }
            
            deckDBChanged = true
            
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
        
        deckDBChanged = true
        
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
            
            deckDBChanged = true
            
        }else {
            throw DataManagerError.NoDeckWithGivenId
        }
    }
    
    func removeDeck(deck:Deck)throws {
        return try removeDeck(withId: deck.id)
    }
    
    
    func flashcard(withId id:String)->Flashcard? {
        
        let selectedFlashcard = realm.objects(Flashcard).filter("_id == '\(id)'").first
        if let flashcard = selectedFlashcard{
            return flashcard.copy() as? Flashcard
        } else {
            return nil
        }
    }
    
    
    func flashcards(forDeckWithId deckId:String) throws ->[Flashcard] {

        let selectedDeck = realm.objects(Deck).filter("_id == '\(deckId)'").first
        if let deck = selectedDeck {
            return deck.flashcards.copy()
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
