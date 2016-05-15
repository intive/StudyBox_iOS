//
//  StudyBox_iOS
//  Created by Kacper Czapp and Damian Malarczyk
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON

struct ManagerMode: OptionSetType {
    var rawValue: Int

    static let Local = ManagerMode(rawValue: 1 << 0)
    static let Remote = ManagerMode(rawValue: 1 << 1)

}

enum DataManagerResponse<T> {
    case Success(obj: T)
    case Error(obj: ErrorType)
}

enum NewDataManagerError: ErrorType {
    case JSONParseError, NoLocalData, ErrorSavingData, ErrorWith(message: String)
}

public class NewDataManager {

    let remoteDataManager = RemoteDataManager()
    let localDataManager = LocalDataManager()

    // Metoda ta obsługuje zapisywanie obiektów do bazy danych
    private func updateInLocalDatabase<DataManagerResponseObject>(parsedObject: DataManagerResponseObject) -> DataManagerResponse<DataManagerResponseObject> {
        if let realmObject = parsedObject as? Object {
            if !self.localDataManager.update(realmObject) {
                return .Error(obj: NewDataManagerError.ErrorSavingData)
            }
            if let parentStoreable = parsedObject as? LocalParentStoreable {
                localDataManager.write { _ in
                    parentStoreable.storeLocalParent(localDataManager)
                }
            }
            
        } else if let realmObjects = parsedObject as? NSArray as? [Object] {
            if !self.localDataManager.update(realmObjects) {
                return .Error(obj: NewDataManagerError.ErrorSavingData)
            }
            localDataManager.write { _ in
                realmObjects.forEach {
                    ($0 as? LocalParentStoreable)?.storeLocalParent(localDataManager)
                }
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
                   remoteDependeciesCount: ((obj: DataManagerResponseObject) -> Int)? = nil,
                   remoteDependecies: ((obj: DataManagerResponseObject, (() -> ())) -> ())? = nil,
                   completion: (DataManagerResponse<DataManagerResponseObject>) -> ()) {

        remoteFetch { response in
            switch response {
            case.Success(let object):
                if let parsedObject = remoteParsing(obj: object) {
                    let updateResult = self.updateInLocalDatabase(parsedObject)
                    if let remoteDependecies = remoteDependecies, var dependeciesCount = remoteDependeciesCount?(obj: parsedObject) where dependeciesCount > 0 {
                        let lock = NSLock()
                        remoteDependecies(obj: parsedObject) {
                            lock.lock()
                            dependeciesCount -= 1
                            if dependeciesCount < 1 {
                                completion(updateResult)
                            }
                            lock.unlock()
                        }
                        return
                    
                    } else {
                        completion(updateResult)
                    }
                    
                } else {
                    completion(.Error(obj: NewDataManagerError.JSONParseError))
                }
            case .Error(let error):
                if let localFetch = localFetch {
                    if let object = localFetch() {
                        completion(.Success(obj: object))
                    } else {
                        completion(.Error(obj: NewDataManagerError.NoLocalData))
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
                   remoteDependeciesCount: ((obj: DataManagerResponseObject) -> Int)? = { _ in
                        return 1
                    },
                   remoteDependecies: ((obj: DataManagerResponseObject, (() -> ())) -> ())? = nil,
                   completion: (DataManagerResponse<DataManagerResponseObject>) -> ()) {
        handleRequest(localFetch: localFetch, remoteFetch: remoteFetch, remoteParsing: remoteParsing,
                      remoteDependeciesCount: remoteDependeciesCount, remoteDependecies: remoteDependecies, completion: completion)

    }

    //convenience method with automated parsing data where remote object is [JSON] and local object conforms to [JSONInitializable]
    private func handleJSONRequest<DataManagerResponseObject: JSONInitializable>(
        localFetch localFetch: (() -> [DataManagerResponseObject])? = nil,
                   remoteFetch: ((ServerResultType<[JSON]>) -> ()) -> (),
                   remoteParsing: (obj: [JSON]) -> [DataManagerResponseObject] = { DataManagerResponseObject.arrayWithJSONArray($0) },
                   remoteDependeciesCount: ((obj: [DataManagerResponseObject]) -> Int)? = {
                        return $0.count
                    },
                   remoteDependecies: ((obj: [DataManagerResponseObject], (() -> ())) -> ())? = nil,
                   completion: (DataManagerResponse<[DataManagerResponseObject]>) -> ()) {
        handleRequest(localFetch: localFetch, remoteFetch: remoteFetch, remoteParsing: remoteParsing,
                      remoteDependeciesCount: remoteDependeciesCount, remoteDependecies: remoteDependecies, completion: completion)
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

    func logout() {
        remoteDataManager.logout()
    }

    //MARK: Decks
    
    
    func deck(withId deckID: String, completion: (DataManagerResponse<Deck>)-> ()) {
        handleJSONRequest(
            localFetch: {
                self.localDataManager.get(Deck.self, withId: deckID)
            },
            remoteFetch: {
                self.remoteDataManager.deck(deckID, completion: $0)
            },
            remoteDependecies: { obj, depenedencyCompletion in
                self.flashcards(obj.serverID) { _ in
                    depenedencyCompletion()
                }
            }, completion: completion)
    }

    func addDeck(deck: Deck, completion: (DataManagerResponse<Deck>)-> ()) {
        handleJSONRequest(
            remoteFetch: {
                self.remoteDataManager.addDeck(deck, completion: $0)
            }, completion: completion)
    }


    
    private var decksDependecies: (obj: [Deck], (() -> ())) -> () {
        return {  objs, dependencyCompletion in
            for obj in objs {
                self.flashcards(obj.serverID) { _ in
                    dependencyCompletion()
                }
            }
            
        }
        
    }
    func decks(includeOwn: Bool? = nil, flashcardsCount: Bool? = nil, name: String? = nil,
               withDependecies: Bool = true, completion: (DataManagerResponse<[Deck]> -> ())) {
        handleJSONRequest(
            localFetch: {
                self.localDataManager.getAll(Deck)
            },
            remoteFetch: {
                self.remoteDataManager.findDecks(includeOwn: includeOwn, flashcardsCount: flashcardsCount,
                    name: name, completion: $0)
            },
            remoteDependeciesCount: {
                return withDependecies ? $0.count : 0
            }, remoteDependecies: decksDependecies, completion: completion)
    }
    
    func userDecks(flashcardsCount: Bool? = nil, withDependecies: Bool = true, completion: (DataManagerResponse<[Deck]>) -> ()) {
        handleJSONRequest(
            localFetch: {
                self.localDataManager.getAll(Deck)
            },
            remoteFetch: {
                self.remoteDataManager.userDecks(completion: $0)
            },
            remoteDependeciesCount: {
                return withDependecies ? $0.count : 0
            }, remoteDependecies: decksDependecies, completion: completion)
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
    
    func decksUser(completion: (DataManagerResponse<[Deck]>)-> ()) {
        handleJSONRequest(
            localFetch: {
                self.localDataManager.getAll(Deck)
            },
            remoteFetch: {
                self.remoteDataManager.findDecksUser(completion: $0)
            }, completion: completion)
    }
    
    func randomDeck(completion: (DataManagerResponse<Deck>)-> ()) {
        handleJSONRequest(
            localFetch: {
                let allDeck = self.localDataManager.getAll(Deck)
                return allDeck[Int(arc4random_uniform(UInt32(allDeck.count) - 1))]
            },
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
}
