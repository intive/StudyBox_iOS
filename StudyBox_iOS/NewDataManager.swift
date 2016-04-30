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
            return baseURL.URLByAppendingPathComponent("\(id)")
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
    private func wrongRequest(responseValue rawJson: AnyObject) -> ServerResultType<JSON> {
        let json = JSON(rawJson)
        if let message = json.dictionary?["message"]?.string {
            return .Error(err: ServerError.ErrorWithMessage(text: message))
        }
        return .Success(obj: json)
    }
    
    // Jeśli udało się zalogować metoda zwróci ServerResultType.Success z obiektem nil,
    // w przeciwnym wypadku obiekt to String z odpowiedzią serwera (powód błędu logowania)
    public func login(username: String, password: String, completion: (ServerResultType<JSON>)->()) {
        request(.GET, url: url(fromRouter: Router.User(child: .Current))).responseJSON {
            
            switch $0.result {
            case .Success(let value):
                
                let wrongRequest = self.wrongRequest(responseValue: value)
                
                if case .Success = wrongRequest {
                    self.username = username
                    self.password = password
                    self.defaults.setObject(username, forKey: UserDefaultsKeys.LoggedUserUsername.rawValue)
                    self.defaults.setObject(password, forKey: UserDefaultsKeys.LoggedUserPassword.rawValue)
                }
                completion(wrongRequest)
                
            case .Failure(let error):
                completion(.Error(err: error))
            }
        }
    }
    
    
    func deck(deckID: String?, completion: (ServerResultType<JSON>) -> ()) {
        var router: Router!
        if let deckID = deckID {
            router = Router.Deck(child: .Single(id: deckID))
        } else {
            router = Router.Deck(child: .All)
        }
        request(.GET, url: url(fromRouter: router)).responseJSON {
            switch $0.result {
            case .Success(let value):
                completion(self.wrongRequest(responseValue: value))
            case .Failure(let error):
                completion(.Error(err: error))
            }
            
        }
    }
    
    
    func findDecks(includeOwn includeOwn: Bool? = nil, flashcardsCount: Bool? = nil, name: String? = nil, completion: (ServerResultType<[JSON]>)->()) {
        let parameters: [String: AnyObject?] = ["includeOwn": includeOwn,
                                                "flashcardsCount": flashcardsCount,
                                                "name": name]
        request(.GET, url: url(fromRouter: Router.Deck(child: .All)), parameters: parameters).responseJSON {
            switch $0.result {
            case .Success(let value):
                let json = JSON(value).arrayValue
                completion(.Success(obj: json))
            case .Failure(let error):
                completion(.Error(err: error))
            }
            
        }
    }
    
    func addFlashcard(deckId: String, flashcardInJSON json: JSON, completion: (ServerResultType<JSON>) -> ()) {
        
        request(.POST, url: url(fromRouter: Router.Flashcards(child: .Post, deckId: deckId))).responseJSON {
            switch $0.result {
            case .Success(let value):
                completion(self.wrongRequest(responseValue: value))
            case .Failure(let error):
                completion(.Error(err: error))
            }
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

public enum DataManagerResponseType {
    case Local, Remote
}

public enum DataManagerResponse<T> {
    case Success(obj: T, responseType: DataManagerResponseType)
    case Error(obj: NewDataManagerError, responseType: DataManagerResponseType)
}

public enum NewDataManagerError: ErrorType {
    case JSONParseError, ServerError(err: ErrorType), NoDeckWithGivenId, ErrorWithMessage(text: String), DataManagerWasDeinitialized
}
private class ModeHandler<T> {
    var local: (() -> DataManagerResponse<T>)?
    
    // wylaczenie ostrzezenia swift lint, aby moc przypisac wartosci poszczegolnym blokom bez ponownego pisania ich typu 
    // force unwrap zamiast optional, poniewaz w przypadku odwolania do serwera powinny zostac obsluzone oba przypadki
    var remote: (remoteSuccess: ((obj: JSON) -> DataManagerResponse<T>)!, //swiftlint:disable:this force_unwrapping
                remoteError: ((obj: ErrorType) -> DataManagerResponse<T>)!)?     //swiftlint:disable:this force_unwrapping

    var remoteRequest: (() -> ())?
    var activeMode: ManagerMode
    var callback: (DataManagerResponse<T>) -> ()
    
    init(withMode mode: ManagerMode, callback: (DataManagerResponse<T>) -> ()) {
        self.activeMode = mode
        self.callback = callback
    }
    
    func start() {
        if activeMode.contains(.Remote) {
            remoteRequest?()
        } else if activeMode == .Local {
            local?()
        }
    }
    
}
public class NewDataManager {
    
    let remoteDataManager = RemoteDataManager()
    let localDataManager = LocalDataManager()
    
    var mode: ManagerMode = [.Local, .Remote]
    
    private func handlerCompletion<T>(handler: ModeHandler<T>) -> (response: ServerResultType<JSON>) -> () {
    
        return { response in
            
            switch response {
            case .Success(let obj):
                if let result = handler.remote?.remoteSuccess(obj: obj) {
                    handler.callback(result)
                }
            case .Error(let obj):
                if handler.activeMode.contains(.Local), let local = handler.local {
                    handler.callback(local())
                } else if let result = handler.remote?.remoteError(obj: obj) {
                    handler.callback(result)
                }
                
            }
            handler.remoteRequest = nil
        }
    }
    
    func getDeck(withDeckId deckID: String, managerCompletion: (DataManagerResponse<Deck>)-> ()) {
       
        let modeBlocks = ModeHandler<Deck>(withMode: mode, callback: managerCompletion)
       
        modeBlocks.remoteRequest = {
            self.remoteDataManager.deck(deckID, completion: self.handlerCompletion(modeBlocks))
        }
        modeBlocks.local = {
            if let deck  = self.localDataManager.get(Deck.self, withId: deckID) {
                return .Success(obj: deck, responseType: .Local)
            } else {
                return .Error(obj: .NoDeckWithGivenId, responseType: .Local)
            }
        }
        
        modeBlocks.remote = (nil, nil)
        
        modeBlocks.remote?.remoteSuccess = {  obj in
            if let deck = Deck.withJSON(obj) {
                self.localDataManager.update(deck)
                return .Success(obj: deck, responseType: .Remote)
            } else {
                return .Error(obj: .JSONParseError, responseType: .Remote)
            }
            
        }
        
        modeBlocks.remote?.remoteError = { obj in
            return .Error(obj: .ServerError(err: obj), responseType: .Remote)
        }
        
        modeBlocks.start()
    }
}
