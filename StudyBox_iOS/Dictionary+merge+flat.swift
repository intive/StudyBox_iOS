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

extension Dictionary {
    //Removes from [Key:Value?] elements that have nil value
    static func flat(dict: Dictionary<Key, Value?>) -> Dictionary<Key, Value> {
        let y  = dict.flatMap { (val) -> (Key, Value)? in
            if let value = val.1  {
                return (val.0, value)
            }
            return nil
        }
        return Dictionary(y)
    }
}
