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
    case JSONParseError, ServerError, NoLocalData, ErrorWith(message: String)
}

public class NewDataManager {
    
    let remoteDataManager = RemoteDataManager()
    let localDataManager = LocalDataManager()
    
    private func handleRequest<ServerResponseObject, DataManagerResponseObject>(mode: ManagerMode,
                               localFetch: (() -> (DataManagerResponseObject?))? = nil,
                               remoteFetch: (((ServerResultType<ServerResponseObject>) -> ())->())? = nil,
                               remoteParsing: ((obj: ServerResponseObject) -> (DataManagerResponseObject?))? = nil ,
                               completion: (DataManagerResponse<DataManagerResponseObject>) -> ()) {
        
        // argumenty mogłyby być tutaj force unwrap, ale chyba lepiej użyć precondition i ewentualnie dać znać o czym zapomnieliśmy
        precondition(mode.contains(.Local) ? localFetch != nil : true, "Local mode requires `localFetch` argument")
        precondition(mode.contains(.Remote) ? remoteFetch != nil && remoteParsing != nil : true,
                     "Remote mode requires `remoteFetch` and `remoteParsing` arguments")
        
        var localBlock:(()-> (DataManagerResponse<DataManagerResponseObject>))?
        
        /// Obsluga roznych trybow - tylko lokalne dane, tylko dane z serwera, badz dane lokalne w przypadku braku dostepu do danych z serwera
        if mode.contains(.Local) {
            localBlock = {
                if let obj = localFetch?() {
                    return .Success(obj: obj)
                } else {
                    return .Error(obj: NewDataManagerError.NoLocalData)
                }
            }
        }
        
        if mode.contains(.Remote) {
            
            remoteFetch? { response in
                switch response {
                case.Success(let obj):
                    
                    if let obj = remoteParsing?(obj: obj) {
                        completion(.Success(obj: obj))
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
    
    private func handleRequest<T: JSONInitializable>(dataManagerResponseObject: T.Type, mode: ManagerMode,
                               localFetch: (() -> T?)? = nil,
                               remoteFetch: ((ServerResultType<JSON>) -> ()) -> (),
                               remoteParsing: (obj: JSON) -> T? = {
                                    return T(withJSON: $0)
                                },
                               completion: (DataManagerResponse<T>) -> ()) {
        handleRequest(mode, localFetch: localFetch, remoteFetch: remoteFetch, remoteParsing: remoteParsing, completion: completion)
        
    }
    
//MARK: Deck/Flashcard/etc. methods
    
    func deck(withId deckID: String, mode: ManagerMode = [.Local, .Remote], completion: (DataManagerResponse<Deck>)-> ()) {
        
        self.handleRequest(Deck.self, mode: mode,
            localFetch: {
                self.localDataManager.get(Deck.self, withId: deckID)
            },
            remoteFetch: {
                self.remoteDataManager.deck(deckID, completion: $0)
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
