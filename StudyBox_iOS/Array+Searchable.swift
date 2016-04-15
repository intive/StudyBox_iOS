//
//  Array+searchable.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 13.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension Array where Element:Searchable {
    
    func matching(expression:String?)->[Element] {
        return filter {
            $0.matches(expression)
        }
        
    }
}
