//
//  Dictionary+merge.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

extension Dictionary {
    init<S: SequenceType
        where S.Generator.Element == Element>
        (_ seq: S) {
        self.init()
        self.merge(seq)
    }
    
    mutating func merge<S: SequenceType
        where S.Generator.Element == Element>
        (seq: S) {
        var gen = seq.generate()
        
        while let x = gen.next() {
            self[x.0] = x.1
        }
    }
}
