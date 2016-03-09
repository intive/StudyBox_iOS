//
//  Array+findUnique.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 04.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension Array where Element: UniquelyIdentifiable {
    
    
    func findUniqe(withId id:String)->Element? {
        for element in self {
            if element.id == id {
                return element
            }
        }
        return nil 
    }
    
    func indexOfUnique(id:String)->Int? {
        for (index,element) in self.enumerate() {
            if element.id == id {
                return index
            }
        }
        return nil 
    }
    
    func generateNewId()->String {
        return NSUUID().UUIDString
    }
    
}
