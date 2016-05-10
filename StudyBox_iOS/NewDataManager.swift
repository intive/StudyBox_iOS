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

enum UserAction {
    case Login, Register
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
                   completion: (DataManagerResponse<DataManagerResponseObject>) -> ()) {

        remoteFetch { response in
            switch response {
            case.Success(let object):
                if let parsedObject = remoteParsing(obj: object) {
                    completion(self.updateInLocalDatabase(parsedObject))
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
    
//    func login(email: String, password: String, completion: (DataManagerResponse<User>) -> ()) {
//        handleRequest(
//            remoteFetch: {
//                self.remoteDataManager.login(email, password: password, completion: $0)
//            },
//            remoteParsing: {
//                self.remoteDataManager.user = User(withJSON: $0, password: password)
//                return self.remoteDataManager.user
//            }, completion: completion)
//    }

    func userAction(action: UserAction, email: String, password: String, completion: (DataManagerResponse<User>) -> ()) {
        var remoteFetch: ((ServerResultType<JSON>) -> ()) -> () = {
            self.remoteDataManager.login(email, password: password, completion: $0)
        }
        
        if case .Register = action {
            remoteFetch = {
                self.remoteDataManager.register(email, password: password, completion: $0)
 
            }
        }
        
        handleRequest(
            remoteFetch: remoteFetch,
            remoteParsing: {
                self.remoteDataManager.user = User(withJSON: $0, password: password)
                return self.remoteDataManager.user
            }, completion: completion
        )
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
            }, completion: completion)
    }

    func addDeck(deck: Deck, completion: (DataManagerResponse<Deck>)-> ()) {
        handleJSONRequest(
            remoteFetch: {
                self.remoteDataManager.addDeck(deck, completion: $0)
            }, completion: completion)
    }

    func decks(includeOwn: Bool? = nil, flashcardsCount: Bool? = nil, name: String? = nil, completion: (DataManagerResponse<[Deck]> -> ())) {
        handleJSONRequest(
            localFetch: {
                self.localDataManager.getAll(Deck)
            }, remoteFetch: {
                self.remoteDataManager.findDecks(includeOwn: includeOwn, flashcardsCount: flashcardsCount, name: name, completion: $0)
            }, completion: completion)
    }
    
    func userDecks(flashcardsCount: Bool? = nil, completion: (DataManagerResponse<[Deck]>) -> ()) {
        handleJSONRequest(
            localFetch: {
                self.localDataManager.getAll(Deck)
            }, remoteFetch: {
                self.remoteDataManager.userDecks(completion: $0)
            }, completion: completion)
    }

    //MARK: Flashcards
    func flashcards(deckID: String, tipsCount: Bool = false, completion: (DataManagerResponse<[Flashcard]>) -> ()) {
        handleJSONRequest(
            localFetch: {
                self.localDataManager.flashcards(deckID)
            }, remoteFetch: {
                self.remoteDataManager.flashcards(deckID, tipsCount: tipsCount, completion: $0)
            }, completion: completion)
    }
    
    
    func flashcard(withId flashcardID: String, deckID: String, completion: (DataManagerResponse<Flashcard>)-> ()) {
        handleJSONRequest(
            localFetch: {
                self.localDataManager.get(Flashcard.self, withId: flashcardID)
            }, remoteFetch: {
                self.remoteDataManager.flashcard(id: flashcardID, deckId: deckID, completion: $0)
            }, completion: completion)
    }
    
    func addFlashcard(flashcard: Flashcard, completion: (DataManagerResponse<Flashcard>) -> ()) {
        handleJSONRequest(
            remoteFetch: {
                self.remoteDataManager.addFlashcard(flashcard, completion: $0)
            }, completion: completion)
    }
    
    func updateFlashcard(flashcard: Flashcard, completion: (DataManagerResponse<Flashcard>) -> ()) {
        handleJSONRequest(
            remoteFetch:{
                self.remoteDataManager.updateFlashcard(flashcard, completion: $0)
            }, remoteParsing: {
                guard let flashcard = Flashcard(withJSON: $0) else {
                    return nil 
                }
                return self.deckInFlashcard([flashcard])[0]
                
            },
            completion: completion)
    }
    
    private func deckInFlashcard(flashcards: [Flashcard]) -> [Flashcard] {
        return flashcards.map {
            $0.deck = localDataManager.get(Deck.self, withId: $0.deckId)
            return $0
        }
    }
}
