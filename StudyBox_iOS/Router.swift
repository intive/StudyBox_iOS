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
    case GetAllUsersDecks(flashcardsCount: Bool?)
    case GetSingleDeck(ID: String)
    case GetRandomDeck(flashcardsCount: Bool?)
    case AddSingleDeck(name: String, isPublic: Bool)
    case RemoveSingleDeck(ID: String)
    case UpdateDeck(ID: String, name: String, isPublic: Bool)
    case ChangeAccessToDeck(ID: String, isPublic: Bool)

    case GetAllFlashcards(deckID: String)
    case GetSingleFlashcard(ID: String, deckID: String)
    case AddSingleFlashcard(deckID: String, question: String, answer: String, isHidden: Bool)
    case RemoveSingleFlashcard(ID: String, deckID: String)
    case UpdateFlashcard(ID: String, deckID: String, question: String, answer: String, isHidden: Bool)

    var method: Alamofire.Method {
        switch self {
        case .GetAllDecks, .GetSingleDeck, .GetAllFlashcards, .GetSingleFlashcard, .GetCurrentUser, .GetAllUsersDecks,
             .GetRandomDeck:
            return .GET
        case .AddSingleFlashcard, .AddSingleDeck, .ChangeAccessToDeck:
            return .POST
        case .RemoveSingleFlashcard, .RemoveSingleDeck:
            return .DELETE
        case .UpdateDeck, .UpdateFlashcard:
            return .PUT
        }
    }

    var path: NSURL {
        switch self {
        case GetCurrentUser:
            return Router.serverURL.URLByAppendingPathComponents(usersPath, "me")

            
        //MARK: Decks
        case GetAllDecks, AddSingleDeck:
            return Router.serverURL.URLByAppendingPathComponents(decksPath)
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks"
            
        case GetAllUsersDecks(_):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, "me")
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks/me"

        case GetSingleDeck(let ID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, ID)
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks/4a31046e-e9cc-4446-bf06-2e07578b2040"
            
        case GetRandomDeck(_):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, "random")
        //example: this returns "http://dev.patronage2016.blstream.com:3000/decks/random"
            
        case RemoveSingleDeck(let ID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, ID)
            //example: this returns	"http://dev.patronage2016.blstream.com:3000/decks/4a31046e-e9cc-4446-bf06-2e07578b2040"
            
        case .UpdateDeck(let ID, _, _) :
            return Router.serverURL.URLByAppendingPathComponents(decksPath, ID)
            //example: this returns	"http://dev.patronage2016.blstream.com:3000/decks/4a31046e-e9cc-4446-bf06-2e07578b2040"
            
            
        case .ChangeAccessToDeck(let ID, let isPublic):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, ID, "public", isPublic.description)
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks/4a31046e-e9cc-4446-bf06-2e07578b2040/public/true"
            
            
        //MARK: Flashcards
        case GetAllFlashcards(let deckID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath)
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks/4a31046e-e9cc-4446-bf06-2e07578b2040/flashcards"
        
        case GetSingleFlashcard(let ID, let deckID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, ID)
            //example: this returns 
            //"http://dev.patronage2016.blstream.com:3000/decks/4a31046e-e9cc-4446-bf06-2e07578b2040/flashcards/27B2CA30-644D-41DB-98BF-55F201049F67"
            
        case AddSingleFlashcard(let deckID, _, _, _):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath)
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks/4a31046e-e9cc-4446-bf06-2e07578b2040/flashcards"

        case RemoveSingleFlashcard(let ID, let deckID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, ID)
            //example: this returns 
            //"http://dev.patronage2016.blstream.com:3000/decks/4a31046e-e9cc-4446-bf06-2e07578b2040/flashcards/27B2CA30-644D-41DB-98BF-55F201049F67"
        
        case .UpdateFlashcard(let ID, let deckID, _, _, _):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, ID)
            //example: this returns 
            //"http://dev.patronage2016.blstream.com:3000/decks/4a31046e-e9cc-4446-bf06-2e07578b2040/flashcards/27B2CA30-644D-41DB-98BF-55F201049F67"
        }
    }

    var URLRequest: NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: self.path)
        request.HTTPMethod = self.method.rawValue
        request.URL = self.path

        switch self {
            //Add only methods that use parameters (check in Apiary)

            
        //MARK: Decks
        case .GetAllDecks(let includeOwn, let flashcardsCount, let name):
            let parameters: [String: AnyObject] = Dictionary.flat(
                [
                    "includeOwn": includeOwn,
                    "flashcardsCount": flashcardsCount,
                    "name": name,
                ])
            return Alamofire.ParameterEncoding.URL.encode(request, parameters: parameters).0
            
        case GetAllUsersDecks(let flashcardsCount):
            let parameters: [String: AnyObject] = Dictionary.flat(
                [
                    "flashcardsCount": flashcardsCount,
                ])
            return Alamofire.ParameterEncoding.URL.encode(request, parameters: parameters).0
       
        case GetRandomDeck(let flashcardsCount):
            let parameters: [String: AnyObject] = Dictionary.flat(
                [
                    "flashcardsCount": flashcardsCount,
                ])
            return Alamofire.ParameterEncoding.URL.encode(request, parameters: parameters).0
            
        case .AddSingleDeck(let name, let isPublic):
            return ParameterEncoding.JSON.encode(request, parameters: ["name": name, "isPublic": isPublic]).0
            
        case .UpdateDeck(_, let name, let isPublic):
            return ParameterEncoding.JSON.encode(request, parameters: ["name": name, "isPublic": isPublic]).0
            
            
        //MARK: Flashcards
        case .AddSingleFlashcard(_, let question, let answer, let isHidden):
            return ParameterEncoding.JSON.encode(request, parameters: ["question": question, "answer": answer, "isHidden": isHidden]).0
        
        case .UpdateFlashcard(_, _, let question, let answer, let isHidden):
            return ParameterEncoding.JSON.encode(request, parameters: ["question": question, "answer": answer, "isHidden": isHidden]).0
            
            
        default: //For methods that don't use parameters
            return request
        }
    }
    
}
