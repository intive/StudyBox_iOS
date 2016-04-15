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

private var settingsServerURL: String = ""
private let defaultServerURL: String = "http://dev.patronage2016.blstream.com:2000"

var serverURL: String {
get {
    if settingsServerURL != "" {
        return settingsServerURL
    } else {
        return defaultServerURL
    }
}
set {
    settingsServerURL = newValue
}
}

class ServerCommunication {
    
    //var userName:String
    //var userPassword:String
    
    let decksURL : String
    
    init(){
        decksURL = serverURL + "/decks"
    }
    
    func getDecksFromServer(completion: (result: [[String: String]]?, error: NSError?) -> Void) {
        Alamofire.request(.GET, decksURL)
            .responseJSON { response in
                switch response.result {
                case .Success:
                    
                    if let result = response.result.value {
                        
                        var list = [[String : String]]()
                        
                        let json = JSON(result)
                        for (_, subJson) in json {
                            
                            list.append(["id" : subJson["id"].stringValue , "name" : subJson["name"].stringValue, "isPublic" : subJson["isPublic"].stringValue])
                        }
                        completion(result: list, error: nil)
                    }
                case .Failure(let error):
                    completion(result: nil, error: error)
                }
        }
    }
    
    
}
