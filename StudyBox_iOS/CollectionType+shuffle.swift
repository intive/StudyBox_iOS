//
//  CollectionType+shuffle.swift
//  StudyBox_iOS
//
//  Created by Piotr Rudnicki on 09.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

/** shuffle array, example:
    let randomized = [1, 2, 3, 4, 5, 6].shuffle(maxElements: 3) //e.g. [6, 1, 5]
    let randomized2 = [1, 2, 3, 4, 5, 6].shuffle() //e.g. [1, 3, 5, 4, 6, 2]
*/

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
