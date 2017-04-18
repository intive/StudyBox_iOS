//
//  StudyBox_iOS
//  Created by Kacper Czapp and Damian Malarczyk
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON

public class DataManager {

    let remoteDataManager = RemoteDataManager()
    let localDataManager = LocalDataManager()

    // Metoda ta obsługuje zapisywanie obiektów do bazy danych
    private func updateInLocalDatabase<DataManagerResponseObject>(parsedObject: DataManagerResponseObject) -> DataManagerResponse<DataManagerResponseObject> {
        if let realmObject = parsedObject as? Object {
            if !self.localDataManager.update(realmObject) {
                return .Error(obj: DataManagerError.ErrorSavingData)
            }
            
        } else if let realmObjects = parsedObject as? NSArray as? [Object] {
            if !self.localDataManager.update(realmObjects) {
                return .Error(obj: DataManagerError.ErrorSavingData)
            }
        } else if let realmObjects = parsedObject as? NSDictionary as? [Object: AnyObject] {
            let toSave = realmObjects.keys
            if !self.localDataManager.update(toSave) {
                return .Error(obj: DataManagerError.ErrorSavingData)
            }
        }
        return .Success(obj: parsedObject)
    }

    // Metoda ta obsługuje generycznie błędy, które mogą wystąpić podczas łączenia się z serwerem
    // jeśli został przekazany parametr localFetch, w przypadku gdy nie uda się połączenie z serwerem dane są pobierane z lokalnej bazy danych
    //
    // localFetch - blok powinien zwrócić dane z lokalnej bazy danych
    // remoteFetch - blok powinien zawołać przekazany blok z danymi z serwera
    // remoteParsing - blok przyjmuje dane typu, który przychodzi z serwera i powinien zwrócić dane typu lokalnego, np. JSON do Deck
    // completion - ten blok jest wołany z obiektem typu lokalnego, np. Deck
    private func handleRequest<ServerResponseObject, DataManagerResponseObject>(
        localFetch localFetch: (() -> (DataManagerResponseObject?))? = nil,
                   remoteFetch: ((ServerResultType<ServerResponseObject>) -> ())->(),
                   remoteParsing: (obj: ServerResponseObject) -> (DataManagerResponseObject?),
                   completion: (DataManagerResponse<DataManagerResponseObject>) -> ()) {

        remoteFetch { response in
            switch response {
            case.Success(let object):
                if let parsedObject = remoteParsing(obj: object) {
                    completion(self.updateInLocalDatabase(parsedObject))
                    
                } else {
                    completion(.Error(obj: DataManagerError.JSONParseError))
                }
            case .Error(let error):
                if let localFetch = localFetch {
                    if let object = localFetch() {
                        completion(.Success(obj: object))
                    } else {
                        completion(.Error(obj: DataManagerError.NoLocalData))
                    }
                } else {
                    completion(.Error(obj: error))
                }
            }
        }
    }

    //convenience method with automated parsing data where remote object is JSON and local object conforms to JSONInitializable
    private func handleJSONRequest<DataManagerResponseObject: JSONInitializable>(
        localFetch localFetch: (() -> DataManagerResponseObject?)? = nil,
                   remoteFetch: ((ServerResultType<JSON>) -> ()) -> (),
                   remoteParsing: (obj: JSON) -> DataManagerResponseObject? = { DataManagerResponseObject(withJSON: $0) },
                   completion: (DataManagerResponse<DataManagerResponseObject>) -> ()) {
        handleRequest(localFetch: localFetch, remoteFetch: remoteFetch, remoteParsing: remoteParsing, completion: completion)
    }

    //convenience method with automated parsing data where remote object is [JSON] and local object conforms to [JSONInitializable]
    private func handleJSONRequest<DataManagerResponseObject: JSONInitializable>(
        localFetch localFetch: (() -> [DataManagerResponseObject])? = nil,
                   remoteFetch: ((ServerResultType<[JSON]>) -> ()) -> (),
                   remoteParsing: (obj: [JSON]) -> [DataManagerResponseObject] = { DataManagerResponseObject.arrayWithJSONArray($0) },
                   completion: (DataManagerResponse<[DataManagerResponseObject]>) -> ()) {
        handleRequest(localFetch: localFetch, remoteFetch: remoteFetch, remoteParsing: remoteParsing, completion: completion)
    }

    //MARK: users
    func login(email: String, password: String, completion: (DataManagerResponse<User>) -> ()) {
        handleRequest(
            remoteFetch: {
                self.remoteDataManager.login(email, password: password, completion: $0)
            },
            remoteParsing: {
                if let jsonDict = $0.dictionary where jsonDict["email"]?.string == email {
                    self.remoteDataManager.user = User(email: email, password: password)
                    return self.remoteDataManager.user
                }
                return nil
            }, completion: completion)
    }

    func register(email: String, password: String, completion: (DataManagerResponse<User>) -> ()) {
        handleRequest(
            remoteFetch: {
                self.remoteDataManager.register(email, password: password, completion: $0)
            },
            remoteParsing: {
                self.remoteDataManager.user = User(email: $0["email"].stringValue, password: password)
                return self.remoteDataManager.user
            },
            completion: completion)
    }

 
    
    func gravatar(completion: (DataManagerResponse<NSData>) -> ()) {
        if let gravatar = self.localDataManager.gravatar() {
            completion(.Success(obj: gravatar))
        } else {
            remoteDataManager.gravatar(localDataManager.gravatarDestinationURL) {
                switch $0 {
                case .Success(let obj):
                    completion(.Success(obj: obj))
                case .Error(let err):
                    completion(.Error(obj: err))
                }
            }
        }
    }
    
    //MARK: Decks
    func deck(withId deckID: String, completion: (DataManagerResponse<Deck>)-> ()) {
        handleJSONRequest(
            localFetch: {
                self.localDataManager.get(Deck.self, withId: deckID)
            },
            remoteFetch: {
                self.remoteDataManager.deck(deckID, completion: $0)
            }, completion: completion)
    }

    func addDeck(deck: Deck, completion: (DataManagerResponse<Deck>)-> ()) {
        handleJSONRequest(
            remoteFetch: {
                self.remoteDataManager.addDeck(deck, completion: $0)
            }, completion: completion)
    }
    
    func decks(includeOwn: Bool? = nil, name: String? = nil, completion: (DataManagerResponse<[Deck]> -> ())) {
        handleJSONRequest(
            localFetch: {
                self.localDataManager.getAll(Deck)
            },
            remoteFetch: {
                self.remoteDataManager.findDecks(includeOwn: includeOwn,
                    name: name, completion: $0)
            }, completion: completion)
    }
    
    private func decksFlashCount(localFetch localFetch: (() -> [Deck])  ,
                                            remoteFetch: ((ServerResultType<[JSON]>) -> ()) -> (),
                                            completion: (DataManagerResponse<([Deck: Int])> -> ())) {
        handleRequest(
            localFetch: {
                let decks = localFetch()
                let count = decks.map {
                    return self.localDataManager.filterCount(Flashcard.self, predicate: "deckId = '\($0.serverID)'")
                }
                return Dictionary(Zip2Sequence(decks, count))
            },
            remoteFetch: remoteFetch,
            remoteParsing: {
                let decks = Deck.arrayWithJSONArray($0)
                let counts = $0.flatMap {
                    return $0["flashcardsCount"].int
                }
                return Dictionary(Zip2Sequence(decks, counts))
            }, completion: completion)
    }
    
   private func decksWithFlashCount(includeOwn: Bool? = nil, name: String? = nil,
                                  completion: (DataManagerResponse<([Deck: Int])> -> ())) {
        decksFlashCount(
            localFetch: {
                self.localDataManager.getAll(Deck)
            },
            remoteFetch:  {
                self.remoteDataManager.findDecks(flashcardsCount: true, includeOwn: includeOwn,
                    name: name, completion: $0)
            }, completion: completion)
    }
    
    private func userDecksWithFlashCount(completion: (DataManagerResponse<[Deck: Int]> -> ())) {
        guard let email = self.remoteDataManager.user?.email else {
            completion(DataManagerResponse.Error(obj: DataManagerError.UserNotLoggedIn))
            return
        }
        decksFlashCount(
            localFetch: {
                self.localDataManager.filter(Deck.self, predicate: "owner = '\(email)'")
            },
            remoteFetch:  {
                self.remoteDataManager.userDecks(flashcardsCount: true, completion: $0)
            }, completion: completion)
        
    }
    
    private func parsingDecksCompletion(response: DataManagerResponse<[Deck: Int]>,
                                        completion: DataManagerResponse<[(Deck, Int)]> -> ()) -> ()  {
        switch response {
        case .Success(let obj):
            
            let tuplesSequence: [(Deck, Int)] = obj.flatMap { $0 }
            completion(.Success(obj: tuplesSequence))
            break
            
        case .Error(let err):
            completion(DataManagerResponse<[(Deck, Int)]>.Error(obj: err))
        }
    }
    
    func userDecksWithFlashcardsCount(completion: (DataManagerResponse<[(Deck, Int)]> -> ())) {
        userDecksWithFlashCount { [weak self] in
            self?.parsingDecksCompletion($0, completion: completion)
        }
    }
   
    func decksWithFlashcardsCount(includeOwn: Bool? = nil,
                                  name: String? = nil, completion: DataManagerResponse<[(Deck, Int)]> -> ()) {
        decksWithFlashCount(includeOwn, name: name) { [weak self] in
            self?.parsingDecksCompletion($0, completion: completion)
        }
    }
    
    func userDecks(completion: (DataManagerResponse<[Deck]>) -> ()) {
        guard let email = self.remoteDataManager.user?.email else {
            completion(DataManagerResponse.Error(obj: DataManagerError.UserNotLoggedIn))
            return
        }
        handleJSONRequest(
            localFetch: {
                self.localDataManager.filter(Deck.self, predicate: "owner = '\(email)'")
            },
            remoteFetch: {
                self.remoteDataManager.userDecks(completion: $0)
            },
            remoteParsing: {
                let decks =  Deck.arrayWithJSONArray($0)
                decks.forEach {
                    $0.owner = email
                }
                return decks
            },
            completion: completion)
    }
    
    func removeDeck(withId deck: Deck, completion: (DataManagerResponse<Void>)-> ()) {
        handleRequest(
            remoteFetch: {
                self.remoteDataManager.removeDeck(deck.serverID, completion: $0)
            },
            remoteParsing: {
                _ = self.localDataManager.delete(deck)
            }, completion: completion)
    }
    
    func randomDeck(completion: (DataManagerResponse<Deck>)-> ()) {
        handleJSONRequest(
            remoteFetch: {
                self.remoteDataManager.findRandomDeck(completion: $0)
            }, completion: completion)
    }
    
    func updateDeck(deck: Deck, completion: (DataManagerResponse<Deck>)-> ()) {
        handleJSONRequest(
            remoteFetch: {
                self.remoteDataManager.updateDeck(deck, completion: $0)
            }, completion: completion)
    }
    
    func changeAccessToDeck(deckID: String, isPublic: Bool, completion: (DataManagerResponse<Void>)-> ()) {
        handleRequest(
            remoteFetch: {
                self.remoteDataManager.changeAccessToDeck(deckID, isPublic: isPublic, completion: $0)
            },
            remoteParsing: {
                if let deck = self.localDataManager.get(Deck.self, withId: deckID){
                    deck.isPublic = isPublic
                    self.localDataManager.update(deck)
                }
                return nil
            }, completion: completion)
    }
    
    //MARK: Flashcards
    func flashcard(withId flashcardID: String, deckID: String, completion: (DataManagerResponse<Flashcard>)-> ()) {
        handleJSONRequest(
            localFetch: {
                self.localDataManager.get(Flashcard.self, withId: flashcardID)
            },
            remoteFetch: {
                self.remoteDataManager.flashcard(deckID, flashcardID: flashcardID, completion: $0)
            }, completion: completion)
    }
    
    func flashcards(deckID: String, completion: (DataManagerResponse<[Flashcard]>) -> ()) {
        handleJSONRequest(
            localFetch: {
                if let deck = self.localDataManager.get(Deck.self, withId: deckID){
                    return deck.flashcards
                } else {
                    return []
                }
            },
            remoteFetch: {
                self.remoteDataManager.findFlashcards(deckID, completion: $0)
            }, completion: completion)
    }
    
    func addFlashcard(flashcard: Flashcard, completion: (DataManagerResponse<Flashcard>) -> ()) {
        handleJSONRequest(
            remoteFetch: {
                self.remoteDataManager.addFlashcard(flashcard, completion: $0)
            }, completion: completion)
    }
    
    func removeFlashcard(flashcard: Flashcard, completion: (DataManagerResponse<Void>) -> ()) {
        handleRequest(
            remoteFetch: {
                self.remoteDataManager.removeFlashcard(flashcard.deckId, flashcardID: flashcard.serverID, completion: $0)
            },
            remoteParsing: {
                _ = self.localDataManager.delete(flashcard)
            }, completion: completion)
    }
    
    func updateFlashcard(flashcard: Flashcard, completion: (DataManagerResponse<Flashcard>) -> ()) {
        handleJSONRequest(
            remoteFetch: {
                self.remoteDataManager.updateFlashcard(flashcard, completion: $0)
            }, completion: completion)
    }

    //Tips
    func addTip(tip: Tip, completion: (DataManagerResponse<Tip>)-> ()) {
        handleJSONRequest(
            remoteFetch: {
                self.remoteDataManager.addTip(tip, completion: $0)
            }, completion: completion)
    }
    
    func removeTip(tip: Tip, completion: (DataManagerResponse<Void>) -> ()) {
        handleRequest(
            remoteFetch: {
                self.remoteDataManager.removeTip(tip, completion: $0)
            },
            remoteParsing: {
                _ = self.localDataManager.delete(tip)
            }, completion: completion)
    }
    
    func tip(withID tipID: String, deckID: String, flashcardID: String, completion: (DataManagerResponse<Tip>)-> ()) {
        handleJSONRequest(
            localFetch: {
                self.localDataManager.get(Tip.self, withId: tipID)
            },
            remoteFetch: {
                self.remoteDataManager.tip(deckID: deckID, flashcardID: flashcardID, tipID: tipID, completion: $0)
            }, completion: completion)
    }
    
    func updateTip(tip: Tip, completion: (DataManagerResponse<Tip>) -> ()) {
        handleJSONRequest(
            remoteFetch: {
                self.remoteDataManager.updateTip(tip, completion: $0)
            }, completion: completion)
    }
    
    func allTipsForFlashcard(deckID: String, flashcardID: String, completion: (DataManagerResponse<[Tip]>)-> ()) {
        handleJSONRequest(
            localFetch: {
                self.localDataManager.filter(Tip.self, predicate: "flashcardID == '\(flashcardID)' AND deckID == '\(deckID)'")
            },
            remoteFetch: {
                self.remoteDataManager.allTips(deckID: deckID, flashcardID: flashcardID, completion: $0)
            }, completion: completion)
    }
    
    func addFlashcardToServer(flashcard:Flashcard , deckId:String) {
        let values = [
            "question": flashcard.question ,
            "answer": flashcard.answer
        ]
        
        Alamofire.request(.POST, "http://private-anon-57cfd8c26-studybox.apiary-mock.com/decks/" + deckId + "/flashcards" , parameters: values , encoding:.JSON)
            .responseJSON{ response in
                
                switch response.result {
                case .Success:
                    try! self.addFlashcard(forDeckWithId: deckId, question: flashcard.question, answer: flashcard.answer, tip:nil)
                    
                case .Failure(_):
                    print("Request failed with error")
                }
        }
        
    }
    
}
