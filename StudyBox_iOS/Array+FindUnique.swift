//
//  Array+findUnique.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 04.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension Array where Element: UniquelyIdentifiable {
    
    
    func findUniqe(withId idUniqe: String) -> Element? {
        for element in self {
            if element.serverID == idUniqe {
                return element
            }
        }
        return nil 
    }
    
    func indexOfUnique(idUniqe: String) -> Int? {
        for (index, element) in self.enumerate() {
            if element.serverID == idUniqe {
                return index
            }
        }
        return nil 
    }
    
    func unqiueElements() -> [Element] {
        var uniques = [Element]()
        self.forEach {
            if uniques.findUniqe(withId: $0.serverID) == nil {
                uniques.append($0)
            }
        }
        return uniques
    }
    
}
