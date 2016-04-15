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
    
    func isValidPassword(minimumCharacters x:Int) -> Bool {
        return hasMinimumCharacters(minimum: x) && !hasWhitespaceOrNewLineCharacter()
    }
    
    func hasMinimumCharacters(minimum x:Int)->Bool {
        return characters.count >= x
    }
    
    func hasWhitespaceOrNewLineCharacter()->Bool {
        return rangeOfCharacterFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != nil
    }
}
