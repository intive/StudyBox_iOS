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
    case GetSingleDeck(ID: String)
    case AddSingleDeck(name: String, isPublic: Bool)

    case GetAllFlashcards(deckID: String)
    case AddSingleFlashcard(deckID: String, question: String, answer: String, isHidden: Bool)
    case GetSingleFlashcard(ID: String, deckID: String)
    case RemoveSingleFlashcard(ID: String, deckID: String)


    var method: Alamofire.Method {
        switch self {
        case .GetAllDecks, GetSingleDeck, GetAllFlashcards, GetSingleFlashcard, GetCurrentUser:
            return .GET
        case .AddSingleFlashcard, AddSingleDeck:
            return .POST
        case .RemoveSingleFlashcard:
            return .DELETE
        }
    }

    var path: NSURL {
        switch self {
        case GetCurrentUser:
            return Router.serverURL.URLByAppendingPathComponents(usersPath, "me")

        case GetAllDecks, AddSingleDeck:
            return Router.serverURL.URLByAppendingPathComponents(decksPath)
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks"

        case GetSingleDeck(let ID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, ID)
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks/4a31046e-e9cc-4446-bf06-2e07578b2040"

        case GetAllFlashcards(let deckID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, "flashcards")
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks/4a31046e-e9cc-4446-bf06-2e07578b2040/flashcards"

        case AddSingleFlashcard(let deckID, _, _, _):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, "flashcards")

        case GetSingleFlashcard(let ID, let deckID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, "flashcards", ID)

        case RemoveSingleFlashcard(let ID, let deckID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, "flashcards", ID)
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

        case .AddSingleDeck(let name, let isPublic):
            return ParameterEncoding.JSON.encode(request, parameters: ["name": name, "isPublic": isPublic]).0

        default: //For methods that don't use parameters
            return request
        }
    }
    
}
