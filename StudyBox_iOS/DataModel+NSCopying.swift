//
//  DataModel+NSCopying.swift
//  StudyBox_iOS
//
//  Created by Piotr Zielinski on 25.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension Array where Element: Flashcard {
    func copy() -> [Flashcard] {
        var flashcards = [Flashcard]()
        for element in self {
            flashcards.append(Flashcard(value: element))
        }
        return flashcards
    }
}

extension Array where Element: Deck {
    func copy() -> [Deck] {
        var decks = [Deck]()
        for element in self {
            decks.append(Deck(value: element))
        }
        return decks
    }
}
