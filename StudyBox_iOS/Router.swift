//
//  Router.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 04.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Alamofire

enum Router: URLRequestConvertible {
    static let defaults = NSUserDefaults.standardUserDefaults()
    static let serverURL = defaults.objectForKey("customServerURLFromSettings") as? NSURL ??
        NSURL(string: "http://dev.patronage2016.blstream.com:3000")! //swiftlint:disable:this force_unwrapping
    
    case GetAllDecks(params: [String: AnyObject]?)
    case GetSingleDeck(id: String)
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
        case .AddSingleFlashcard:
            return .POST
        case .RemoveSingleFlashcard:
            return .DELETE
        }
    }
    
    var path: NSURL {
        switch self {
        case GetAllDecks:
            return Router.serverURL.URLByAppendingPathComponent("decks")
            
        case GetSingleDeck(let id):
            return Router.serverURL.URLByAppendingElements(["decks", id])
            
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
        
//        if let username = Router.username,
//            let password = Router.password {
//            request.allHTTPHeaderFields = ["Authentication": "\(username):\(password)-encodedwithbase64"]
//        }
        
        switch self {
        //Add only methods that use parameters (check in Apiary)
        case .GetAllDecks(let params):
            return Alamofire.ParameterEncoding.URL.encode(request, parameters: params).0
        case .GetAllFlashcards(_, let params):
            return Alamofire.ParameterEncoding.URL.encode(request, parameters: params).0
            
        default: //for methods that don't use parameters
            return request
        }
    }
    
}
