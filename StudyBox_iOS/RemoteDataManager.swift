//
//  RemoteDataManager.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 04.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Alamofire
import SwiftyJSON
import Reachability

enum ServerError: ErrorType {
    case ErrorWithMessage(text: String), NoInternetAccess
}

enum ServerResultType<T> {
    case Success(obj: T)
    case Error(err: ErrorType)
}

class RemoteDataManager {
    
    var user: User?
   
    private var basicAuth: String? {
        if let user = user {
            if let basicEncoded = "\(user.email):\(user.password)".base64Encoded() {
                return "Basic \(basicEncoded)"
            }
        }
        return nil
    }

    // Metoda sprawdza czy odpowiedź serwera zawiera pole 'message' - jeśli tak oznacza to, że coś poszło nie tak,
    // w przypadku jego braku dostajemy dane o które prosiliśmy
    private func performGenericRequest<ObjectType>(
        request: URLRequestConvertible,
        completion: (ServerResultType<ObjectType>)->(),
        successAction: (JSON) -> (ObjectType)) {
        
        guard Reachability.isConnected() else {
            completion(.Error(err: ServerError.NoInternetAccess))
            return
        }
        let mutableRequest = request.URLRequest
        if let basic = basicAuth {
            mutableRequest.addValue(basic, forHTTPHeaderField: "Authorization")
        }
        Alamofire.request(mutableRequest).responseJSON { response in
            switch response.result {
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
    }

    //convenience method when ServerResultType is JSON
    private func performRequest(
        request: URLRequestConvertible,
        completion: (ServerResultType<JSON>)->()) {
        performGenericRequest(request, completion: completion) { $0 }
    }

    //convenience method when ServerResultType is [JSON]
    private func performRequest(
        request: URLRequestConvertible,
        completion: (ServerResultType<[JSON]>)->()) {
        performGenericRequest(request, completion: completion) { $0.arrayValue }
    }

    
    //MARK: Users
    func login(email: String, password: String, completion: (ServerResultType<JSON>)->()) {
        guard let basicAuth = "\(email):\(password)".base64Encoded() else {
            completion(.Error(err: (ServerError.ErrorWithMessage(text: "Niepoprawne dane"))))
            return
        }
        let loginRequest = Router.GetCurrentUser.URLRequest
        loginRequest.addValue("Basic \(basicAuth)", forHTTPHeaderField: "Authorization")

        performRequest(loginRequest, completion: completion)
    }
    
    func register(email: String, password: String, completion: (ServerResultType<JSON>) -> ()) {
        performRequest(Router.AddUser(email: email, password: password), completion: completion)
    }
    
    func logout() {
        user = nil
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(Utils.NSUserDefaultsKeys.LoggedUserEmail)
        defaults.removeObjectForKey(Utils.NSUserDefaultsKeys.LoggedUserPassword)
    }
    
    func saveEmailPassInDefaults(email: String, pass: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(email, forKey: Utils.NSUserDefaultsKeys.LoggedUserEmail)
        defaults.setObject(pass, forKey: Utils.NSUserDefaultsKeys.LoggedUserPassword)
    }
    
    func getEmailPassFromDefaults() -> (email: String, password: String)? {
        let defaults = NSUserDefaults.standardUserDefaults()
        let email = defaults.objectForKey(Utils.NSUserDefaultsKeys.LoggedUserEmail) as? String
        let password = defaults.objectForKey(Utils.NSUserDefaultsKeys.LoggedUserPassword) as? String
        
        if let email = email, password = password {
            return (email, password)
        } else {
            return nil
        }
    }
    
    
    //MARK: Decks
    func findDecks(includeOwn includeOwn: Bool? = nil, flashcardsCount: Bool? = nil, name: String? = nil, completion: (ServerResultType<[JSON]>)->()) {
        performRequest(Router.GetAllDecks(includeOwn: includeOwn, flashcardsCount: flashcardsCount, name: name), completion: completion)
    }
    
    func deck(deckID: String, completion: (ServerResultType<JSON>) -> ()) {
        performRequest(Router.GetSingleDeck(ID: deckID), completion: completion)
    }
    
    func findRandomDeck(flashcardsCount: Bool? = nil, completion: (ServerResultType<JSON>)->()) {
        performRequest(Router.GetRandomDeck(flashcardsCount: flashcardsCount), completion: completion)
    }
    
    func userDecks(flashcardsCount: Bool? = nil, completion: (ServerResultType<[JSON]>) -> ()) {
        performRequest(Router.GetAllUsersDecks(flashcardsCount: flashcardsCount), completion: completion)
    }

    func addDeck(deck: Deck, completion: (ServerResultType<JSON>) -> ()) {
        performRequest(Router.AddSingleDeck(name: deck.name, isPublic: deck.isPublic), completion: completion)
    }
    
    func removeDeck(deckID: String, completion: (ServerResultType<Void>) -> ()) {
        performGenericRequest(Router.RemoveSingleDeck(ID: deckID), completion: completion){ _ in
            return
        }
    }
    
    func updateDeck(deck: Deck, completion: (ServerResultType<JSON>) -> ()) {
        performRequest(Router.UpdateDeck(ID: deck.serverID, name: deck.name, isPublic: deck.isPublic), completion: completion)
    }
    
    func changeAccessToDeck(deckID: String, isPublic: Bool, completion: (ServerResultType<Void>) -> ()) {
        performGenericRequest(Router.ChangeAccessToDeck(ID: deckID, isPublic: isPublic), completion: completion){ _ in
            return
        }
    }
    

    //MARK: Flashcards
    func findFlashcards(deckID: String, completion: (ServerResultType<[JSON]>) -> ()) {
        performRequest(Router.GetAllFlashcards(deckID: deckID), completion: completion)
    }
    
    func flashcard(deckID: String, flashcardID: String, completion: (ServerResultType<JSON>) -> ()) {
        performRequest(Router.GetSingleFlashcard(ID: flashcardID, deckID: deckID), completion: completion)
    }
    
    func addFlashcard(flashcard: Flashcard, completion: (ServerResultType<JSON>) -> ()) {
        performRequest(Router.AddSingleFlashcard(deckID: flashcard.deckId, question: flashcard.question, answer: flashcard.answer, isHidden: flashcard.hidden),
                       completion: completion)
    }
    
    func removeFlashcard(deckID: String, flashcardID: String, completion: (ServerResultType<Void>) -> ()) {
        performGenericRequest(Router.RemoveSingleFlashcard(ID: flashcardID, deckID: deckID), completion: completion){ _ in
            return
        }
    }
    
    func updateFlashcard(flashcard: Flashcard, completion: (ServerResultType<JSON>) -> ()) {
        performRequest(Router.UpdateFlashcard(ID: flashcard.serverID, deckID: flashcard.deckId,
            question: flashcard.question, answer: flashcard.answer, isHidden: flashcard.hidden),
                       completion: completion)
    }
    
    //MARK: Tips

    // swiftlint:disable:next function_parameter_count
    func addTip(deckID deckID: String, flashcardID: String, tipID: String, content: String, difficulty: Int, completion: (ServerResultType<JSON>)->()) {
        performRequest(Router.AddTip(deckID: deckID, flashcardID: flashcardID, content: content, difficulty: difficulty), completion: completion)
    }

    func tip(deckID deckID: String, flashcardID: String, tipID: String, completion: (ServerResultType<JSON>)->()) {
        performRequest(Router.GetTip(deckID: deckID, flashcardID: flashcardID, tipID: tipID), completion: completion)
    }
    
    func allTips(deckID deckID: String, flashcardID: String, completion: (ServerResultType<[JSON]>) -> ()) {
        performRequest(Router.GetAllTips(deckID: deckID, flashcardID: flashcardID), completion: completion)
    }
    
    // swiftlint:disable:next function_parameter_count
    func updateTip(deckID deckID: String, flashcardID: String, tipID: String,
                          content: String, difficulty: Int, completion: (ServerResultType<JSON>)->()) {
        performRequest(Router.UpdateTip(deckID: deckID, flashcardID: flashcardID, tipID: tipID,
            content: content, difficulty: difficulty), completion: completion)
    }
    
    func removeTip(deckID deckID: String, flashcardID: String, tipID: String, completion: (ServerResultType<Void>)->()) {
        performGenericRequest(Router.RemoveTip(deckID: deckID, flashcardID: flashcardID, tipID: tipID), completion: completion){ _ in
            return
        }
    }
    
    func addTip(tip: Tip, completion: (ServerResultType<JSON>)->()) {
        addTip(deckID: tip.deckID, flashcardID: tip.flashcardID, tipID: tip.serverID, content: tip.content, difficulty: tip.difficulty, completion: completion)
    }
    
    func tip(tip: Tip, completion: (ServerResultType<JSON>)->()) {
        performRequest(Router.GetTip(deckID: tip.deckID, flashcardID: tip.flashcardID, tipID: tip.serverID), completion: completion)
    }
    
    func updateTip(tip: Tip, completion: (ServerResultType<JSON>)->()) {
        updateTip(deckID: tip.deckID, flashcardID: tip.flashcardID, tipID: tip.serverID,
                  content: tip.content, difficulty: tip.difficulty, completion: completion)
    }
    
    func removeTip(tip: Tip, completion: (ServerResultType<Void>) -> ()) {
        removeTip(deckID: tip.deckID, flashcardID: tip.flashcardID, tipID: tip.serverID, completion: completion)
    }
    
}
