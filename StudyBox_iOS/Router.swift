//
//  Router.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 04.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Alamofire

private let usersPath = "users"
private let decksPath = "decks"
private let flashcardsPath = "flashcards"

enum Router: URLRequestConvertible {
    private static var serverURL = NSURL(string: "http://dev.patronage2016.blstream.com:3000")! //swiftlint:disable:this force_unwrapping

    case GetCurrentUser

    case GetAllDecks(includeOwn: Bool?, flashcardsCount: Bool?, name: String?)
    case GetAllUserDecks(flashcardsCount: Bool?)
    case GetSingleDeck(ID: String)
    case AddSingleDeck(name: String, isPublic: Bool)

    case GetAllFlashcards(deckID: String)
    case AddSingleFlashcard(deckID: String, question: String, answer: String, isHidden: Bool)
    case GetSingleFlashcard(ID: String, deckID: String)
    case UpdateFlashcard(ID: String, deckID: String, question: String, answer: String, isHidden: Bool)
    case RemoveSingleFlashcard(ID: String, deckID: String)
    

    var method: Alamofire.Method {
        switch self {
        case .GetAllDecks, GetSingleDeck, GetAllFlashcards, GetSingleFlashcard, GetCurrentUser, GetAllUserDecks:
            return .GET
        case .AddSingleFlashcard, AddSingleDeck:
            return .POST
        case .RemoveSingleFlashcard:
            return .DELETE
        case .UpdateFlashcard:
            return .PUT
        }
    }

    var path: NSURL {
        switch self {
        case GetCurrentUser:
            return Router.serverURL.URLByAppendingPathComponents(usersPath, "me")

        case GetAllDecks, AddSingleDeck:
            return Router.serverURL.URLByAppendingPathComponents(decksPath)
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks"o
        
        case GetAllUserDecks(_):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, "me")

        case GetSingleDeck(let ID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, ID)
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks/4a31046e-e9cc-4446-bf06-2e07578b2040"

        case GetAllFlashcards(let deckID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath)
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks/4a31046e-e9cc-4446-bf06-2e07578b2040/flashcards"

        case AddSingleFlashcard(let deckID, _, _, _):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath)

        case GetSingleFlashcard(let ID, let deckID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, ID)

        case RemoveSingleFlashcard(let ID, let deckID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, ID)
            
        case .UpdateFlashcard(let ID, let deckID, _, _, _):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, ID)
        }
    }

    var URLRequest: NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: self.path)
        request.HTTPMethod = self.method.rawValue
        request.URL = self.path

        switch self {
            //Add only methods that use parameters (check in Apiary)

        case .GetAllDecks(let includeOwn, let flashcardsCount, let name):
            let parameters: [String: AnyObject] = Dictionary.flat(
                [
                    "includeOwn": includeOwn,
                    "flashcardsCount": flashcardsCount,
                    "name": name,
                ])
            return Alamofire.ParameterEncoding.URL.encode(request, parameters: parameters).0
        
        case .GetAllUserDecks(let flashcardsCount):
            let parameters: [String: AnyObject] = Dictionary.flat(
                [
                    "flashcardsCount" : flashcardsCount
                ])
            
            return Alamofire.ParameterEncoding.URL.encode(request, parameters: parameters).0

        case .AddSingleDeck(let name, let isPublic):
            return ParameterEncoding.JSON.encode(request, parameters: ["name": name, "isPublic": isPublic]).0
            
        case .AddSingleFlashcard(_, let question, let answer, let isHidden):
            return ParameterEncoding.JSON.encode(request, parameters: ["question" : question, "answer" : answer, "isHidden" : isHidden]).0
            
        case .UpdateFlashcard(_, _, let question, let answer, let isHidden):
            return ParameterEncoding.JSON.encode(request, parameters: ["question" : question, "answer" : answer, "isHidden" : isHidden]).0

        default: //For methods that don't use parameters
            return request
        }
    }
    
}
