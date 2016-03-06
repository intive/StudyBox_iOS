//
//  Array+findUnique.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 04.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension Array {
    
    
    /**
     If array elements are of type `UniqueModelId` the method will return element with ID param
     - parameter withId: id to look for
    */
    func findUniqe(withId id:String)->Element? {
        var i = 0;
        while (i < self.count){
            if let current = self[i] as? UniqueModelId {
                if (current.id == id){
                    return self[i]
                }
            }
            i = i + 1;
        }
        
        return nil
    }
    
}
