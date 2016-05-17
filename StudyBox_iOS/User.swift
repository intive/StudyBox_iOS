//
//  User.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 05.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//
import SwiftyJSON
struct User {
    var email: String
    var password: String
    
    init?(withJSON json: JSON, password: String) {
        if let email = json.dictionary?["email"]?.string {
            self = User(email: email, password: password)
        } else {
            return nil
        }
        
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
