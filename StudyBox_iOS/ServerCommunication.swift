//
//  ServerCommunication.swift
//  StudyBox_iOS
//
//  Created by Mariusz Koziel on 13.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

private var settingsServerURL: String?
private let defaultServerURL: String = "http://dev.patronage2016.blstream.com:3000"

var serverURL: String {
get {
    if let settingsServerURL = settingsServerURL {
        return settingsServerURL
    } else {
        return defaultServerURL
    }
}
set {
    settingsServerURL = newValue
}
}

enum ServerResult <T> {
    case Success(T)
    case Failure(NSError)
}

class ServerCommunication {
    
    //var userName:String
    //var userPassword:String
    
    let decksURL: String
    
    init(){
        decksURL = serverURL + "/decks"
    }
    
    func getDecksFromServer(completion: ServerResult<[Deck]> -> Void) {
        Alamofire.request(.GET, decksURL)
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    
                    let json = JSON(value)
                    var DecksArray = [Deck]()
                    
                    for (_, subJson) in json {
                        DecksArray.append(Deck(serverID: subJson["id"].stringValue, name: subJson["name"].stringValue))
                    }
                    completion(.Success(DecksArray))
                case .Failure(let error):
                    completion(.Failure(error))
                }
        }
    }
    //sending flashcard to server , returns true if succeed
    func sendFlashcardToServer(flashcard: Flashcard, deckId: String) -> Bool {
        let values: [String: AnyObject] = [
            "question": flashcard.question, "answer": flashcard.answer, "isHidden": flashcard.hidden
        ]
        
        let valid = NSJSONSerialization.isValidJSONObject(values)
        var returnedValue: String = ""
        
        if valid{
            Alamofire.request(.POST, serverURL + "/decks/" + deckId + "/flashcards", parameters: values, encoding:.JSON)
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        returnedValue = response.description
                    case .Failure(let error):
                        print("Request failed with error \(error)")
                        returnedValue = response.description
                    }
            }
        } else {
            print("Invalid JSON object")
        }
        if returnedValue == "201" {
            return true
        } else {
            return false
        }
    }
}
