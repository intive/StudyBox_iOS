//
//  DataModel+NSCopying.swift
//  StudyBox_iOS
//
//  Created by Piotr Zielinski on 25.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension Flashcard: NSCopying {
    func copyWithZone(zone: NSZone) -> AnyObject {
        return Flashcard(value: self)
    }
}

extension Deck: NSCopying {
    func copyWithZone(zone: NSZone) -> AnyObject {
        return Deck(value: self)
    }
}

extension Array where Element: Flashcard {
    func copy() -> [Flashcard] {
        var flashcards = [Flashcard]()
        for element in self {
            flashcards.append(element.copy() as! Flashcard)
        }
        return flashcards
    }
}

extension Array where Element: Deck {
    func copy() -> [Deck] {
        var decks = [Deck]()
        for element in self {
            decks.append(element.copy() as! Deck)
        }
        return decks
    }
}
