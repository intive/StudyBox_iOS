//
//  RemoteDataManager.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 04.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Alamofire
import SwiftyJSON

enum ServerError: ErrorType {
    case ErrorWithMessage(text: String)
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
    
    func logout() {
        user = nil
    }
    
    func register(email: String, password: String, completion: (ServerResultType<JSON>) -> ()) {
        performRequest(Router.AddUser(email: email, password: password), completion: completion)
    }

    //MARK: Decks
    
    func deck(deckID: String, completion: (ServerResultType<JSON>) -> ()) {
        performRequest(Router.GetSingleDeck(ID: deckID), completion: completion)
    }
    
    func findDecks(includeOwn includeOwn: Bool? = nil, flashcardsCount: Bool? = nil, name: String? = nil, completion: (ServerResultType<[JSON]>)->()) {
        performRequest(Router.GetAllDecks(includeOwn: includeOwn, flashcardsCount: flashcardsCount, name: name).URLRequest, completion: completion)
    }

    func addDeck(deck: Deck, completion: (ServerResultType<JSON>) -> ()) {
        performRequest(Router.AddSingleDeck(name: deck.name, isPublic: deck.isPublic), completion: completion)
    }

    //MARK: Flashcards
    func addFlashcard(deckID: String, flashcard: Flashcard, completion: (ServerResultType<JSON>) -> ()) {
        performRequest(Router.AddSingleFlashcard(deckID: deckID, question: flashcard.question, answer: flashcard.answer, isHidden: flashcard.hidden),
                       completion: completion)
    }
    
}
