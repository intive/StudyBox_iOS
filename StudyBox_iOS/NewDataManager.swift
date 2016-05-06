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
    case JSONParseError, ServerError, NoLocalData, ErrorSavingData, ErrorWith(message: String)
}

public class NewDataManager {
    
    let remoteDataManager = RemoteDataManager()
    let localDataManager = LocalDataManager()
    
    private func handleLocalUpdate<DataManagerResponseObject>(parsedObj: DataManagerResponseObject,
                                   completion: (DataManagerResponse<DataManagerResponseObject>) -> ()) {
        if let realmObj = parsedObj as? Object {
            if self.localDataManager.update(realmObj) {
                completion(.Success(obj: parsedObj))
            } else {
                completion(.Error(obj: NewDataManagerError.ErrorSavingData))
            }
        } else if let realmObjects = (parsedObj as? NSArray) as? [Object] {
            var results = [Object]()
            realmObjects.forEach {
                if self.localDataManager.update($0) {
                    results.append($0)
                }
            }
            if let returnResults = (results as NSArray) as? DataManagerResponseObject {
                completion(.Success(obj: returnResults))
            }
        } else {
            completion(.Success(obj: parsedObj))
        }
    }
    
    private func handleRequest<ServerResponseObject, DataManagerResponseObject>(mode: ManagerMode,
                               localFetch: (() -> (DataManagerResponseObject?))? = nil,
                               remoteFetch: ((ServerResultType<ServerResponseObject>) -> ())->(),
                               remoteParsing: (obj: ServerResponseObject) -> (DataManagerResponseObject?),
                               completion: (DataManagerResponse<DataManagerResponseObject>) -> ()) {
        // argumenty mogłyby być tutaj force unwrap, ale chyba lepiej użyć precondition i ewentualnie dać znać o czym zapomnieliśmy

        
        var localBlock:(()-> (DataManagerResponse<DataManagerResponseObject>))?
        
        /// Obsluga roznych trybow - tylko lokalne dane, tylko dane z serwera, badz dane lokalne w przypadku braku dostepu do danych z serwera
        if mode.contains(.Local) {
            
            if let localFetch = localFetch {
                localBlock = {
                    if let obj = localFetch() {
                        return .Success(obj: obj)
                    } else {
                        return .Error(obj: NewDataManagerError.NoLocalData)
                    }
                }
            } else {
                fatalError("Local mode requires `localFetch` argument")
            }
        }
        
        if mode.contains(.Remote) {
            
            remoteFetch { response in
                switch response {
                case.Success(let obj):
                    if let parsedObj = remoteParsing(obj: obj) {
                        self.handleLocalUpdate(parsedObj, completion: completion)
                    } else {
                        completion(.Error(obj: NewDataManagerError.JSONParseError))
                    }
                case .Error:
                    if let localBlock = localBlock {
                        completion(localBlock())
                    } else {
                        completion(.Error(obj: NewDataManagerError.ServerError))
                    }
                }
            }
        } else if let localBlock = localBlock {
            completion(localBlock())
        }
    }
    
    private func handleRequest<T: JSONInitializable>(mode: ManagerMode,
                               localFetch: (() -> T?)? = nil,
                               remoteFetch: ((ServerResultType<JSON>) -> ()) -> (),
                               remoteParsing: (obj: JSON) -> T? = { json in
                                    return T(withJSON: json)
                                },
                               completion: (DataManagerResponse<T>) -> ()) {
        handleRequest(mode, localFetch: localFetch, remoteFetch: remoteFetch, remoteParsing: remoteParsing, completion: completion)
        
    }
    
    private func handleRequest<T: JSONInitializable>(mode: ManagerMode,
                               localFetch: (() -> [T])? = nil,
                               remoteFetch: ((ServerResultType<[JSON]>) -> ()) -> (),
                               remoteParsing: (obj: [JSON]) -> [T] = {
                                    return T.arrayWithJSONArray($0)
                               },
                               completion: (DataManagerResponse<[T]>) -> ()) {
        handleRequest(mode, localFetch: localFetch, remoteFetch: remoteFetch, remoteParsing: remoteParsing, completion: completion)
    }
    
    
    func deck(withId deckID: String, mode: ManagerMode = [.Local, .Remote], completion: (DataManagerResponse<Deck>)-> ()) {
        
        handleRequest(mode,
            localFetch: {
                self.localDataManager.get(Deck.self, withId: deckID)
            },
            remoteFetch: {
                self.remoteDataManager.deck(deckID, completion: $0)
            },
            completion: completion
        )
        
    }
    
    func addDeck(deck: Deck, completion: (DataManagerResponse<Deck>)-> ()) {
        handleRequest(.Remote,
            remoteFetch: {
                self.remoteDataManager.addDeck(deck, completion: $0)
            },
            completion: completion
        )
    }
    
    func decks(mode: ManagerMode = .Remote, completion: (DataManagerResponse<[Deck]> -> ()), includeOwn: Bool?, flashcardsCount: Bool?, name: String?) {
        
        handleRequest(mode,
            localFetch: {
                self.localDataManager.getAll(Deck)
            }, remoteFetch: {
                self.remoteDataManager.findDecks(includeOwn: includeOwn, flashcardsCount: flashcardsCount, name: name, completion: $0)
            },
            completion: completion
        )
    }
    
    func login(email: String, password: String, completion: (DataManagerResponse<User>) -> ()) {
        self.handleRequest(.Remote,
            remoteFetch: {
                self.remoteDataManager.login(email, password: password, completion: $0)
            },
            remoteParsing: {
                if let jsonDict = $0.dictionary, email = jsonDict["email"]?.string {
                    let loggedUsr = User(email: email, password: password)
                    self.remoteDataManager.user = loggedUsr
                    return loggedUsr
                }
                return nil
            },
            completion: completion
        )
    }
    
    func logout() {
        remoteDataManager.logout()
    }
}
