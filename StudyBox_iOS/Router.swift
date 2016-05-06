//
//  Router.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 04.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Alamofire

enum Router: URLRequestConvertible {
    static var serverURL = NSURL(string: "http://dev.patronage2016.blstream.com:3000")! //swiftlint:disable:this force_unwrapping
    
    case GetAllDecks(params: [String: AnyObject]?)
    case GetSingleDeck(id: String)
    case AddSingleDeck(name: String, isPublic: Bool)
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
        case .AddSingleFlashcard, AddSingleDeck:
            return .POST
        case .RemoveSingleFlashcard:
            return .DELETE
        }
    }
    
    var path: NSURL {
        switch self {
        case GetAllDecks, AddSingleDeck:
            return Router.serverURL.URLByAppendingPathComponent("decks") //use when only one element
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks"
            
        case GetSingleDeck(let id):
            return Router.serverURL.URLByAppendingElements(["decks", id]) //use when multiple elements
            //example: this returns "http://dev.patronage2016.blstream.com:3000/decks/12345678-9012-3456-7890-123456789012"
            
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
        
        switch self {
        //Add only methods that use parameters (check in Apiary)
            
        case .GetAllDecks(let params):
            return Alamofire.ParameterEncoding.URL.encode(request, parameters: params).0
            
        case .GetAllFlashcards(_, let params):
            return Alamofire.ParameterEncoding.URL.encode(request, parameters: params).0
            
        default: //For methods that don't use parameters
            return request
        }
    }
    
}
