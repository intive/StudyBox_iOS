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
                               localFetch:() -> (DataManagerResponseObject?),
                               remoteFetch: ((ServerResultType<ServerResponseObject>) -> ())->(),
                               remoteParsing: (obj: ServerResponseObject) -> (DataManagerResponseObject?),
                               completion: (DataManagerResponse<DataManagerResponseObject>) -> ()) {
        
        var localBlock:(()-> (DataManagerResponse<DataManagerResponseObject>))?
        
        /// Obsluga roznych trybow - tylko lokalne dane, tylko dane z serwera, badz dane lokalne w przypadku braku dostepu do danych z serwera
        if mode.contains(.Local) {
            localBlock = {
                if let obj = localFetch() {
                    return .Success(obj: obj)
                } else {
                    return .Error(obj: NewDataManagerError.NoLocalData)
                }
            }
        }
        
        if mode.contains(.Remote) {
            remoteFetch { response in
                switch response {
                case.Success(let obj):
                    if let obj = remoteParsing(obj: obj) {
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
    
    func deck(withId deckID: String, mode: ManagerMode = [.Local, .Remote], completion: (DataManagerResponse<Deck>)-> ()) {
        
        self.handleRequest(mode,
            localFetch: {
                self.localDataManager.get(Deck.self, withId: deckID)
            },
            remoteFetch: {
                self.remoteDataManager.deck(deckID, completion: $0)
            },
            remoteParsing: {
                return Deck.withJSON($0)
            },
            completion: completion
        )
        
    }
    
    func login(username: String, password: String, completion: (DataManagerResponse<User?>) -> ()) {
        self.handleRequest(.Remote,
            localFetch: {
                return nil
            },
            remoteFetch: {
                self.remoteDataManager.login(username, password: password, completion: $0)
            },
            remoteParsing: {
                return $0
            },
           completion: completion
        )
    }
    
    func logout() {
        remoteDataManager.logout()
    }
}
