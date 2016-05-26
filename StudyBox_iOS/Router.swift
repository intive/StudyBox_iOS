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
private let tipsPath = "tips"
private let flashcardsPath = "flashcards"

enum Router: URLRequestConvertible {
    private static var serverURL = NSURL(string: "http://dev.patronage2016.blstream.com:2000")! //swiftlint:disable:this force_unwrapping

    case GetCurrentUser
    case AddUser(email: String, password: String)

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
    
    case GetAllTips(deckID: String, flashcardID: String)
    case AddTip(deckID: String, flashcardID: String, content: String, difficulty: Int)
    case GetTip(deckID: String, flashcardID: String, tipID: String)
    case UpdateTip(deckID: String, flashcardID: String, tipID: String, content: String, difficulty: Int)
    case RemoveTip(deckID: String, flashcardID: String, tipID: String)

    var method: Alamofire.Method {
        switch self {
        case .GetAllDecks, .GetSingleDeck, .GetAllFlashcards, .GetSingleFlashcard, .GetCurrentUser, .GetAllUsersDecks,
             .GetRandomDeck, .GetTip, .GetAllTips:
            return .GET
        case .AddSingleFlashcard, .AddSingleDeck, AddUser, .ChangeAccessToDeck, .AddTip:
            return .POST
        case .RemoveSingleFlashcard, .RemoveSingleDeck, .RemoveTip:
            return .DELETE
        case .UpdateDeck, .UpdateFlashcard, .UpdateTip:
            return .PUT
        }
    }

    var path: NSURL {
        switch self {
        case GetCurrentUser:
            return Router.serverURL.URLByAppendingPathComponents(usersPath, "me")
            
        case AddUser:
            return Router.serverURL.URLByAppendingPathComponents(usersPath)

            
        //MARK: Decks
        case GetAllDecks, AddSingleDeck:
            return Router.serverURL.URLByAppendingPathComponents(decksPath)
            
        case GetAllUsersDecks(_):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, "me")
            
        case GetSingleDeck(let ID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, ID)
            
        case GetRandomDeck(_):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, "random")
            
        case RemoveSingleDeck(let ID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, ID)
            
        case .UpdateDeck(let ID, _, _) :
            return Router.serverURL.URLByAppendingPathComponents(decksPath, ID)
            
            
        case .ChangeAccessToDeck(let ID, let isPublic):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, ID, "public", isPublic.description)
            
            
        //MARK: Flashcards
        case GetAllFlashcards(let deckID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath)
        
        case GetSingleFlashcard(let ID, let deckID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, ID)
            
        case AddSingleFlashcard(let deckID, _, _, _):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath)

        case RemoveSingleFlashcard(let ID, let deckID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, ID)
        
        case .UpdateFlashcard(let ID, let deckID, _, _, _):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, ID)
          
        //Tips
        case GetAllTips(let deckID, let flashcardID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, flashcardID, tipsPath)
        
        case AddTip(let deckID, let flashcardID, _, _):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, flashcardID, tipsPath)
    
        case GetTip(let deckID, let flashcardID, let tipID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, flashcardID, tipsPath, tipID)
            
        case UpdateTip(let deckID, let flashcardID, let tipID, _, _):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, flashcardID, tipsPath, tipID)
            
        case RemoveTip(let deckID, let flashcardID, let tipID):
            return Router.serverURL.URLByAppendingPathComponents(decksPath, deckID, flashcardsPath, flashcardID, tipsPath, tipID)
        
        }
    }
    
    private func verboseParameters(inout dict: [String: AnyObject]) {
        for (key, value) in dict {
            if let boolVal = value as? Bool {
                dict[key] = boolVal ? "true" : "false"
            }
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: self.path)
        request.HTTPMethod = self.method.rawValue
        request.URL = self.path
        var parameters: [String: AnyObject] = [:]
        switch self {
            //Add only methods that use parameters (check in Apiary)
            
        //MARK: Decks
        case .GetAllDecks(let includeOwn, let flashcardsCount, let name):
            parameters = Dictionary.flat(
                [
                    "includeOwn": includeOwn,
                    "flashcardsCount": flashcardsCount,
                    "name": name,
                ])
            
        case GetAllUsersDecks(let flashcardsCount):
            parameters = Dictionary.flat(
                [
                    "flashcardsCount": flashcardsCount,
                ])
            
        case GetRandomDeck(let flashcardsCount):
            parameters = Dictionary.flat(
                [
                    "flashcardsCount": flashcardsCount,
                ])
            
        case .AddSingleDeck(let name, let isPublic):
            return ParameterEncoding.JSON.encode(request, parameters: ["name": name, "isPublic": isPublic]).0
            
        case .AddUser(let email, let password):
            return ParameterEncoding.JSON.encode(request, parameters: ["email": email, "password": password]).0
            
            
        case .UpdateDeck(_, let name, let isPublic):
            return ParameterEncoding.JSON.encode(request, parameters: ["name": name, "isPublic": isPublic]).0
            
            
        //MARK: Flashcards
        case .AddSingleFlashcard(_, let question, let answer, let isHidden):
            return ParameterEncoding.JSON.encode(request, parameters: ["question": question, "answer": answer, "isHidden": isHidden]).0
        
        case .UpdateFlashcard(_, _, let question, let answer, let isHidden):
            return ParameterEncoding.JSON.encode(request, parameters: ["question": question, "answer": answer, "isHidden": isHidden]).0
            
        
        //Tips
        case .UpdateTip(let deckID, let flashcardID, let tipID, _, _ ):
            return ParameterEncoding.JSON.encode(request, parameters: ["deckId": deckID, "flashcardId": flashcardID, "tipId": tipID]).0
        
        case .RemoveTip(let deckID, let flashcardID, let tipID):
            return ParameterEncoding.JSON.encode(request, parameters: ["deckId": deckID, "flashcardId": flashcardID, "tipId": tipID]).0
            
            
        default: //For methods that don't use parameters
            return request
        }
        verboseParameters(&parameters)
        return Alamofire.ParameterEncoding.URL.encode(request, parameters: parameters).0
        
    }
    
}
