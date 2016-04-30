//
//  StudyBox_iOS
//
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire
import SwiftyJSON

enum FlashcardRoutes {
    case Post
    
    func url(baseURL: NSURL) -> NSURL {
        switch self {
        case .Post:
            return baseURL.URLByAppendingPathComponent("flashcards")
        }
    }
}

enum DeckRoutes  {
    case Single(id:String)
    case All
    func url(baseURL: NSURL) -> NSURL {
        switch self {
        case .Single(let id):
            return baseURL.URLByAppendingPathComponent(id)
        case .All:
            return baseURL
        }
    }
}

enum UserRoutes  {
    case Current
    case None
    
    func url(baseURL: NSURL) -> NSURL {
        switch self {
        case .Current:
            return baseURL.URLByAppendingPathComponent("me")
        case .None:
            return baseURL
        }
    }
}

// prywatna klasa trzymająca adresy endpointów
enum Router {
    
    case User(child: UserRoutes)
    case Deck(child: DeckRoutes)
    case Flashcards(child: FlashcardRoutes, deckId: String)
    
    func URL(baseURL: NSURL) -> NSURL {
        switch self {
        case User(let child):
            
            let url = baseURL.URLByAppendingPathComponent("users")
            return child.url(url)
        case Deck(let child):
            let url = baseURL.URLByAppendingPathComponent("decks")
            return child.url(url)
            
        case Flashcards(let child, let deckId):
            var url = baseURL.URLByAppendingPathComponent("decks")
            url = url.URLByAppendingPathComponent(deckId)
            return child.url(url)
            
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

//
////tylko w tej klasie odbywa się komunikacja z serwerem i trzyma stan sesji, opakowuje ona Alamofire

enum UserDefaultsKeys: String {
    case LoggedUserUsername = "username"
    case LoggedUserPassword = "password"
}

public class RemoteDataManager {
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private lazy var username: String? = self.defaults.stringForKey(UserDefaultsKeys.LoggedUserUsername.rawValue)
    private lazy var password: String? = self.defaults.stringForKey(UserDefaultsKeys.LoggedUserPassword.rawValue)
    
    private let serverURL = NSURL(string: "http://dev.patronage2016.blstream.com:3000")! //swiftlint:disable:this force_unwrapping
    //
    private func sharedHeaders() -> [String: String]? {
        if let username = username,
            let password = password {
            return ["Authentication": "\(username):\(password)-encodedwithbase64"]
        }
        return nil
    }
    
    private func url(fromRouter router: Router) -> NSURL {
        return router.URL(serverURL)
    }
    
    
    private func request(method: Alamofire.Method, url: NSURL, parameters: [String: AnyObject?]? = nil) -> Request { //swiftlint:disable:this variable_name
        let params = parameters.flatMap { $0 as? [String: AnyObject] }
        return Alamofire.request(method, url, parameters: params, headers: sharedHeaders())
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
        request(.GET, url: url(fromRouter: Router.User(child: .Current))).responseJSON {
            self.handleResponse(responseResult: $0.result, completion: completion) { json in
                self.username = username
                self.password = password
                self.defaults.setObject(username, forKey: UserDefaultsKeys.LoggedUserUsername.rawValue)
                self.defaults.setObject(password, forKey: UserDefaultsKeys.LoggedUserPassword.rawValue)
                return json
            }
        }
    }
    
    
    func deck(deckID: String, completion: (ServerResultType<JSON>) -> ()) {
        let router = Router.Deck(child: .Single(id: deckID))
        request(.GET, url: url(fromRouter: router)).responseJSON {
            self.handleResponse(responseResult: $0.result, completion: completion)
        }
    }
    
    
    func findDecks(includeOwn includeOwn: Bool? = nil, flashcardsCount: Bool? = nil, name: String? = nil, completion: (ServerResultType<[JSON]>)->()) {
        let parameters: [String: AnyObject?] = ["includeOwn": includeOwn,
                                                "flashcardsCount": flashcardsCount,
                                                "name": name]
        request(.GET, url: url(fromRouter: Router.Deck(child: .All)), parameters: parameters).responseJSON {
            self.handleResponse(responseResult: $0.result, completion: completion) { json in
                return json.arrayValue
            }
        }
    }
    
    func addFlashcard(deckId: String, flashcardInJSON json: JSON, completion: (ServerResultType<JSON>) -> ()) {
        
        request(.POST, url: url(fromRouter: Router.Flashcards(child: .Post, deckId: deckId))).responseJSON {
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

extension Deck {
    class func withJSON(json: JSON) -> Deck? {
        if let jsonDict = json.dictionary {
            if let id = jsonDict["id"]?.string, name = jsonDict["name"]?.string {
                return Deck(serverID: id, name: name)
            }
        }
        return nil
    }
    
    class func arrayWithJSON(json: JSON) -> [Deck] {
        var decks = [Deck]()
        if let jsonArray = json.array {
            jsonArray.forEach {
                if let deck = Deck.withJSON($0) {
                    decks.append(deck)
                }
            }
        }
        return decks
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
