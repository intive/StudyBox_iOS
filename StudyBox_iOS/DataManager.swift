//
//  DataManager.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import RealmSwift

enum DataManagerError: ErrorType {
    case NoDeckWithGivenId, NoFlashcardWithGivenId, NoRealm
}

/**
 Class responisble for handling data model stored in memory
*/
class DataManager {
    
    private var decks = [Deck]()
    // private var flashcards = [Flashcard]()
    private let realm = try? Realm()
    // dzięki deckDBChanged talie będą wczytywane z bazy tylko w przypadku zmiany tabeli Deck
    // !!! Zmiana tabeli Flashcard nie jest brana pod uwagę
    private var deckDBChanged: Bool = true
    
    init(){
        
        // usuwanie tylko wtedy gdy jest internet i najpewniej nie w tym miejscu. Na razie ze względu na 
        // DummyData
        // TODOs: relocate removeDecksFromDatabase() and check for internet connection
        removeDecksFromDatabase()
    }
    
    func decks(sorted: Bool) -> [Deck] {
        
        // wczytuje talie jeśli nastąpiła zmiana w tabeli talii w bazie lub puste
        if deckDBChanged || decks.isEmpty {
            loadDecksFromDatabase()
        }

        if sorted {
            return decks.sort {
                $0.name < $1.name
            }
        }
        return decks.copy()
    }
    
    // loading decks from Realm. Used for refresh after changing decks in db
    func loadDecksFromDatabase(forced: Bool = false) {
        
        if !decks.isEmpty || forced {
            decks.removeAll()
        }
        
        if let realm = realm {
            decks = realm.objects(Deck).toArray()
        }
        
        // jako że załadowane talie z pamięci zgadzają się z tymi z bazy, to false
        deckDBChanged = false
    }
    
    func removeDecksFromDatabase() {
        if let realm = realm {
            do {
                try realm.write() {
                    realm.deleteAll()
                }
            } catch let e {
                debugPrint(e)
            }
        }
        deckDBChanged = true
    }
    
    func deck(withId idDeck: String) -> Deck? {
        
        if let realm = realm {
            if let deck = realm.objects(Deck).filter("serverID == '\(idDeck)'").first {
                return deck
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func deck(withName name: String, caseSensitive: Bool = false) -> Deck? {
        let decksData = decks(false)
        
        if caseSensitive {
            for deck in decksData {
                if deck.name == name {
                    return deck
                }
            }
        } else {
            let lowercaseName = name.lowercaseString
            for deck in decksData {
                if deck.name.lowercaseString == lowercaseName {
                    return deck
                }
            }
        }
        
        return nil
    }
    
    func updateDeck(deck: Deck) throws {
        
        if let realm = realm {
            if let updatingDeck = realm.objects(Deck).filter("serverID == '\(deck.serverID)'").first{
                do {
                    try realm.write {
                        updatingDeck.name = deck.name
                        deckDBChanged = true
                    }
                } catch let e {
                    debugPrint(e)
                }
            } else {
                DataManagerError.NoDeckWithGivenId
            }
        } else {
            throw DataManagerError.NoRealm
        }
    }
    
    func addDeck(name: String) -> String {

        let id = decks.generateNewId()
        let newDeck = Deck(serverID: id, name: name)
        
        if let realm = realm {
            do {
                try realm.write() {
                    realm.add(newDeck)
                }
            } catch let e {
                debugPrint(e)
            }
        }
        deckDBChanged = true
        return id
    }

    func removeDeck(withId idDeck: String) throws {
        
        if let realm = realm {
                if let deck = realm.objects(Deck).filter("serverID == '\(idDeck)'").first {
                    let toRemove = deck.flashcards
                    do {
                        try realm.write {
                            realm.delete(toRemove)
                            realm.delete(deck)
                        }
                    } catch let e {
                        debugPrint(e)
                    }
                    deckDBChanged = true
                } else {
                    throw DataManagerError.NoDeckWithGivenId
                }
            
        } else {
            throw DataManagerError.NoRealm
        }
    }
    
    func removeDeck(deck: Deck) throws {
        return try removeDeck(withId: deck.serverID)
    }
    
    func flashcard(withId idFlashcard: String) -> Flashcard? {
        
        if let realm = realm {
            if let flashcard = realm.objects(Flashcard).filter("serverID == '\(idFlashcard)'").first{
                return flashcard
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    func flashcards(forDeckWithId deckId: String) throws ->[Flashcard] {
        if let realm = realm {
            if let deck = realm.objects(Deck).filter("serverID == '\(deckId)'").first {
                return deck.flashcards.copy()
            } else {
                throw DataManagerError.NoDeckWithGivenId
            }
        } else {
            throw DataManagerError.NoRealm
        }
    }
    
    func flashcards(forDeck deck: Deck) throws ->[Flashcard] {
        return try flashcards(forDeckWithId: deck.serverID)
    }

    func updateFlashcard(data: Flashcard) throws {
        if let realm = realm {
            if let flashcard = realm.objects(Flashcard).filter("serverID == '\(data.serverID)'").first {
                do {
                    try realm.write {
                        flashcard.question = data.question
                        flashcard.answer = data.answer
                        flashcard.tip = data.tip
                        flashcard.hidden = data.hidden
                        flashcard.deck = data.deck
                    }
                } catch let e {
                    debugPrint(e)
                }
            } else {
                throw DataManagerError.NoFlashcardWithGivenId
            }
        } else {
            throw DataManagerError.NoRealm
        }
    }
    
    func addFlashcard(forDeckWithId deckId: String, question: String, answer: String, tip: Tip?)throws -> String  {
        let flashcardId = NSUUID().UUIDString
        if let realm = realm {
            if let selectedDeck = realm.objects(Deck).filter("serverID == '\(deckId)'").first {
                let newFlashcard = Flashcard(serverID: flashcardId, deckId: deckId, question: question, answer: answer, tip: tip)
            
                newFlashcard.deck = selectedDeck
                do {
                    try realm.write {
                        realm.add(newFlashcard)
                    }
                } catch let e {
                    debugPrint(e)
                }
                
            } else {
                throw DataManagerError.NoDeckWithGivenId
            }
        } else {
            throw DataManagerError.NoRealm
        }
        return flashcardId
    }
    
    func addFlashcard(forDeck deck: Deck, question: String, answer: String, tip: Tip?)throws -> String  {
        return try addFlashcard(forDeckWithId: deck.serverID, question: question, answer: answer, tip: tip)
    }
    
    func removeFlashcard(withId idFlashcard: String) throws {
        if let realm = realm {
            if let flashcardToremove = realm.objects(Flashcard).filter("serverID == '\(idFlashcard)'").first {
                do {
                    try realm.write {
                        realm.delete(flashcardToremove)
                    }
                } catch let e {
                    debugPrint(e)
                }
            } else {
                throw DataManagerError.NoFlashcardWithGivenId
            }
        } else {
            throw DataManagerError.NoRealm
        }
    }
    
    func removeFlashcard(data: Flashcard)throws {
        return try removeFlashcard(withId: data.serverID)
    }
    
    func hideFlashcard(withId idFlashcard: String) throws {
        if let realm = realm {
            if let flashcardToUnHide = realm.objects(Flashcard).filter("serverID == '\(idFlashcard)'").first {
                do {
                    try realm.write {
                        flashcardToUnHide.hidden = true
                    }
                } catch let e {
                    debugPrint(e)
                }
                
            } else {
                throw DataManagerError.NoFlashcardWithGivenId
            }
        } else {
            throw DataManagerError.NoRealm
        }
    }
    
    func unhideFlashcard(withId idFlashcard: String) throws {
        if let realm = realm {
            if let flashcardToHide = realm.objects(Flashcard).filter("serverID == '\(idFlashcard)'").first {
                do {
                    try realm.write {
                        flashcardToHide.hidden = false
                    }
                } catch let e {
                    debugPrint(e)
                }
            } else {
                throw DataManagerError.NoFlashcardWithGivenId
            }
        } else {
            throw DataManagerError.NoRealm
        }
    }
}
