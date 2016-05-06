//
//  JSONInstantiable.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 05.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol JSONInitializable {
    init?(withJSON json: JSON)
    init()
    
}

extension JSONInitializable {
    static func arrayWithJSON(json: JSON) -> [Self] {
        var objs = [Self]()
        if let jsonArray = json.array {
            objs.appendContentsOf(arrayWithJSONArray(jsonArray))
        }
        return objs
    }
    
    static func arrayWithJSONArray(jsonArray: [JSON]) -> [Self] {
        var objs = [Self]()
        jsonArray.forEach {
            if let obj = Self(withJSON: $0) {
                objs.append(obj)
            }
        }
        return objs
        
    }
}
