//
//  StudyBox_iOS
//  Created by Kacper Czapp and Damian Malarczyk
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON

enum Router: URLRequestConvertible {
    static let defaults = NSUserDefaults.standardUserDefaults()
    static let serverURL = defaults.objectForKey("customServerURLFromSettings") as? NSURL ??
        NSURL(string: "http://dev.patronage2016.blstream.com:3000")! //swiftlint:disable:this force_unwrapping
    
    static var username: String? = defaults.stringForKey(Utils.NSUserDefaultsKeys.LoggedUserUsername) ?? "studyBoxiOS@patronage.com"
    static var password: String? = defaults.stringForKey(Utils.NSUserDefaultsKeys.LoggedUserPassword) ?? "StudyBoxPassword"
    
    case GetAllDecks(params: [String: AnyObject]?)
    case GetSingleDeck(id: String)
    //dodać RemoveDeck, UpdateDeck
    
    case GetAllFlashcards(inDeckID: String, params: [String:AnyObject]?)
    case AddSingleFlashcard(question: String, answer: String, isHidden: Bool)
    case GetSingleFlashcard(inDeckID: String, flashcardID: String)
    case RemoveSingleFlashcard(inDeckID: String, flashcardID: String)
    
    case GetCurrentUser
    //dodać AddUser
    
    var method: Alamofire.Method {
        switch self {
        case .GetAllDecks, GetSingleDeck, GetAllFlashcards, GetSingleFlashcard, GetCurrentUser:
            return .GET
        case .AddSingleFlashcard:
            return .POST
        case .RemoveSingleFlashcard:
            return .DELETE
        }
    }
    
    var path: NSURL {
        switch self {
        case GetAllDecks:
            return Router.serverURL.URLByAppendingPathComponent("decks")
            
        case GetSingleDeck(let id):
            return Router.serverURL.URLByAppendingElements(["decks", id])
            
        case GetCurrentUser:
            return Router.serverURL.URLByAppendingElements(["users", "me"])
            
            /*...*/
        default:
            return Router.serverURL
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: self.path)
        request.HTTPMethod = self.method.rawValue
        request.URL = self.path
        
        if let username = Router.username,
            let password = Router.password {
            request.allHTTPHeaderFields = ["Authentication": "\(username):\(password)-encodedwithbase64"]
        }
        
        switch self {
        //Add only methods that use parameters (check in Apiary)
        case .GetAllDecks(let params):
            return Alamofire.ParameterEncoding.URL.encode(request, parameters: params).0
        case .GetAllFlashcards(_, let params):
            return Alamofire.ParameterEncoding.URL.encode(request, parameters: params).0
            
        default: //for methods that don't use parameters
            return request
        }
    }
    
}

public enum ServerError: ErrorType {
    case ErrorWithMessage(text: String)
}

public enum ServerResultType<T> {
    case Success(obj: T)
    case Error(err: ErrorType)
}

public class RemoteDataManager {
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private func sharedHeaders() -> [String: String]? {
        if let username = Router.username,
            let password = Router.password {
            return ["Authentication": "\(username):\(password)-encodedwithbase64"]
        }
        return nil
    }
    
    // Metoda sprawdza czy odpowiedź serwera zawiera pole 'message' - jeśli tak oznacza to, że coś poszło nie tak,
    // w przypadku jego braku dostajemy dane o które prosiliśmy
    private func handleResponse<T>(responseResult result: Alamofire.Result<AnyObject, NSError>,
                                completion: (ServerResultType<T>)->(),
                                successAction: ((JSON) -> (T))) {
        switch result {
        case .Success(let val):
            let json = JSON(val)
            if let message = json.dictionary?["message"]?.string {
                completion(.Error(err: ServerError.ErrorWithMessage(text: message)))
            } else {
                completion(.Success(obj: successAction(json)))
            }
            
        case .Failure(let err):
            completion(.Error(err: err))
        }
        
    }
    
    private func handleResponse(responseResult result: Alamofire.Result<AnyObject, NSError>,
                                               completion: (ServerResultType<JSON>)->(),
                                               successAction: ((JSON) -> ())? = nil ) {
        handleResponse(responseResult: result, completion: completion) { json in
            return json
        }
    }
    
    // Jeśli udało się zalogować metoda zwróci ServerResultType.Success z obiektem nil,
    // w przeciwnym wypadku obiekt to String z odpowiedzią serwera (powód błędu logowania)
    public func login(username: String, password: String, completion: (ServerResultType<JSON>)->()) {
        request(Router.GetCurrentUser).responseJSON {
            self.handleResponse(responseResult: $0.result, completion: completion) { json in
                self.defaults.setObject(username, forKey: Utils.NSUserDefaultsKeys.LoggedUserUsername)
                self.defaults.setObject(password, forKey: Utils.NSUserDefaultsKeys.LoggedUserPassword)
                return json
            }
        }
    }
    
    func deck(deckID: String, completion: (ServerResultType<JSON>) -> ()) {
        request(Router.GetSingleDeck(id: deckID)).responseJSON {
            self.handleResponse(responseResult: $0.result, completion: completion)
        }
    }
    
    
    func findDecks(includeOwn includeOwn: Bool? = nil, flashcardsCount: Bool? = nil, name: String? = nil, completion: (ServerResultType<[JSON]>)->()) {
        let parameters: [String: AnyObject?] =
            ["includeOwn": includeOwn,
             "flashcardsCount": flashcardsCount,
             "name": name]

        let flatMap = Dictionary.flat(parameters)
        
        request(Router.GetAllDecks(params: flatMap).URLRequest).responseJSON {
            self.handleResponse(responseResult: $0.result, completion: completion) { json in
                return json.arrayValue
            }
        }
    }
    
    func addFlashcard(deckId: String, flashcard: Flashcard, completion: (ServerResultType<JSON>) -> ()) {
        
        request(Router.AddSingleFlashcard(question: flashcard.question, answer: flashcard.answer, isHidden: flashcard.hidden)).responseJSON {
            self.handleResponse(responseResult: $0.result, completion: completion)
        }
    }
    
    func addDeck(deck: Deck, completion: (ServerResultType<JSON>) -> ()) {
        
        request(Router.GetSingleDeck(id: deck.serverID)).responseJSON {
            self.handleResponse(responseResult: $0.result, completion: completion)
        }
    }
}

class LocalDataManager {
    private let realm = try? Realm()
    
    func write(@noescape block: (realm: Realm) -> ()) -> Bool {
        guard let realm = realm else {
            return false
        }
        
        do {
            try realm.write {
                block(realm: realm)
            }
        } catch (let error) {
            debugPrint(error)
            return false
        }
        return true
    }
    
    func get<T: Object>(type: T.Type, withId idKey: String) -> T? {
        return realm?.objectForPrimaryKey(T.self, key: idKey)
    }
    
    func getAll<T: Object>(type: T.Type) -> [T] {
        return realm?.objects(T.self).toArray() ?? []
    }
    
    func filter<T: Object>(type: T.Type, predicate: String, args: AnyObject...) -> [T] {
        return realm?.objects(T.self).filter(predicate, args).toArray() ?? []
    }
    
    func update(object: Object) -> Bool {
        return write { realm in
            realm.add(object, update: true)
        }
    }
    
    func delete (object: Object) -> Bool {
        return write { realm in
            realm.delete(object)
        }
    }
    
}

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
}
