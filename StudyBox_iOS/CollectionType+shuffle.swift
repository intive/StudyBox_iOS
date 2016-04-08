//
//  CollectionType+shuffle.swift
//  StudyBox_iOS
//
//  Created by Piotr Rudnicki on 08.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension CollectionType {
    
    @warn_unused_result
    func  shuffle(maxElements maxElements: Int = Int.max) -> [Self.Generator.Element] {
        var elements: [Self.Generator.Element] = []
        var tmpSelf = Array(self)
        
        let max = min(tmpSelf.count, maxElements)
        for _ in 0..<max {
            let randomIndex = arc4random_uniform(UInt32(tmpSelf.count))
            
            var currentIndex = tmpSelf.startIndex
            for _ in 0..<randomIndex {
                currentIndex = currentIndex.successor()
            }
            
            let element = tmpSelf.removeAtIndex(currentIndex)
            elements.append(element)
        }
        
        return elements
    }
}
