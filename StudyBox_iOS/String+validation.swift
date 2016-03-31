//
//  String+validation.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 31.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation


extension String {
    
    func trimWhiteCharacters() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func isValidEmail() -> Bool {
        return !containsString(" ") && containsString("@")
    }
    
    func isValidPassword() -> Bool {
        return characters.count > 7 && rangeOfCharacterFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == nil
    }
}
