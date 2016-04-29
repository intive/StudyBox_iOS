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
            return baseURL.URLByAppendingPathComponent("/flashcards")
        }
    }
}

enum DeckRoutes  {
    case Get(id:String?)
    
    func url(baseURL: NSURL) -> NSURL {
        switch self {
        case .Get(let id):
            if let id = id {
                return baseURL.URLByAppendingPathComponent("/\(id)")
            }
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
            return baseURL.URLByAppendingPathComponent("/me")
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
            
            let url = baseURL.URLByAppendingPathComponent("/users")
            return child.url(url)
        case Deck(let child):
            let url = baseURL.URLByAppendingPathComponent("/decks")
            return child.url(url)
            
        case Flashcards(let child, let deckId):
            let url = baseURL.URLByAppendingPathComponent("/decks/\(deckId)")
            return child.url(url)
            
        }
        
    }
}


public enum ServerResultType<T> {
    case Success(obj: T)
    case WrongRequest(obj: String)
    case Error(error: ErrorType)
}
//
////tylko w tej klasie odbywa się komunikacja z serwerem i trzyma stan sesji, opakowuje ona Alamofire

enum UserData: String {
    case Username = "username"
    case Password = "password"
}

public class RemoteDataManager {
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private lazy var username: String? = self.defaults.stringForKey(UserData.Username.rawValue)
    private lazy var password: String? = self.defaults.stringForKey(UserData.Password.rawValue)
    
    private let serverURL = NSURL(string: "https://studyboxurl.com")! //swiftlint:disable:this force_unwrapping
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
    private func wrongRequest(response rawJson: AnyObject) -> ServerResultType<JSON> {
        let json = JSON(rawJson)
        if let message = json.dictionary?["message"]?.string {
            return .WrongRequest(obj: message)
        }
        return .Success(obj: json)
    }
    
    // Jeśli udało się zalogować metoda zwróci ServerResultType.Success z obiektem nil,
    // w przeciwnym wypadku obiekt to String z odpowiedzią serwera (powód błędu logowania)
    public func login(username: String, password: String, completion: (ServerResultType<String?>)->()) {
        request(.GET, url: url(fromRouter: Router.User(child: .Current))).responseJSON {
            
            switch $0.result {
            case .Success(let value):
                
                let json = JSON(value)
                
                if let message = json.dictionary?["message"]?.string {
                    completion(.WrongRequest(obj: message))
                } else {
                    self.username = username
                    self.password = password
                    self.defaults.setObject(username, forKey: UserData.Username.rawValue)
                    self.defaults.setObject(password, forKey: UserData.Password.rawValue)
                    
                    completion(.Success(obj: nil))
                }
                
            case .Failure(let error):
                completion(.Error(error: error))
            }
        }
    }
    
    
    func deck(deckID: String?, completion: (ServerResultType<JSON>) -> ()) {
        request(.GET, url: url(fromRouter: Router.Deck(child: .Get(id: deckID)))).responseJSON {
            switch $0.result {
            case .Success(let value):
                completion(self.wrongRequest(response: value))
            case .Failure(let error):
                completion(.Error(error: error))
            }
            
        }
    }
    
    
    func findDecks(includeOwn includeOwn: Bool? = nil, flashcardsCount: Bool? = nil, name: String? = nil, completion: (ServerResultType<[JSON]>)->()) {
        let parameters: [String: AnyObject?] = ["includeOwn": includeOwn,
                                                "flashcardsCount": flashcardsCount,
                                                "name": name]
        request(.GET, url: url(fromRouter: Router.Deck(child: .Get(id: nil))), parameters: parameters).responseJSON {
            switch $0.result {
            case .Success(let value):
                let json = JSON(value).arrayValue
                completion(.Success(obj: json))
            case .Failure(let error):
                completion(.Error(error: error))
            }
            
        }
    }
    
    func addFlashcard(deckId: String, flashcardInJSON json: JSON, completion: (ServerResultType<JSON>) -> ()) {
        
        request(.POST, url: url(fromRouter: Router.Flashcards(child: .Post, deckId: deckId))).responseJSON {
            switch $0.result {
            case .Success(let value):
                completion(self.wrongRequest(response: value))
            case .Failure(let error):
                completion(.Error(error: error))
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
    
    func get<T: Object>(withId idKey: String) -> T? {
        return realm?.objectForPrimaryKey(T.self, key: idKey)
    }
    
    func get<T: Object>(filter: String?) -> [T]? {
        return realm?.objects(T.self).toArray()
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
        //parse JSON
        return Deck(serverID: "", name: "")
    }
}



struct ManagerMode: OptionSetType {
    var rawValue: Int
    
    static let Local = ManagerMode.init(rawValue: 1 << 0)
    static let Remote = ManagerMode.init(rawValue: 1 << 1)
    
}

enum DataManagerResponse<T, E> {
    case Success(obj: T)
    case Error(obj: E)
}

enum NewDataManagerError: ErrorType {
    case JSONParseError, ServerError, NoDeckWithGivenId, ErrorWith(message: String)
}

public class NewDataManager {
    
    let remoteDataManager = RemoteDataManager()
    let localDataManager = LocalDataManager()
    


    func getDeck(withDeckId deckID: String, mode: ManagerMode, managerCompletion: (DataManagerResponse<Deck, NewDataManagerError>)-> ()) {
       
        var localBlock:(()-> (DataManagerResponse<Deck, NewDataManagerError>))?
        
        /// Obsluga roznych trybow - tylko lokalne dane, tylko dane z serwera, badz dane lokalne w przypadku braku dostepu do danych z serwera
        if mode.contains(.Local) {
            localBlock = {
                if let deck: Deck = self.localDataManager.get(withId: deckID) {
                    return .Success(obj: deck)
                } else {
                    return .Error(obj: .NoDeckWithGivenId)
                }
            }
        }
        
        if mode.contains(.Remote) {
            remoteDataManager.deck(deckID, completion: { (response) in
                switch response {
                case.Success(let obj):
                    if let deck = Deck.withJSON(obj) {
                        managerCompletion(.Success(obj: deck))
                    } else {
                        managerCompletion(.Error(obj: .JSONParseError))
                    }
                case .Error:
                    if let localBlock = localBlock {
                        managerCompletion(localBlock())
                    } else {
                        managerCompletion(.Error(obj: .ServerError))
                    }
                case .WrongRequest(let msg):
                    managerCompletion(.Error(obj: .ErrorWith(message: msg)))
                }
                
            })
        } else if let localBlock = localBlock {
            managerCompletion(localBlock())
        }
    }
}
