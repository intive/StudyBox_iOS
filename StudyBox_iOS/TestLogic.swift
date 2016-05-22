//
//  TestLogic.swift
//  StudyBox_iOS
//
//  Created by user on 12.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

enum StudyType {
    case Test(uint), Learn
}

class Test {
    private var flashcards: [Flashcard]
    private(set) var deck: Deck
    private(set) var notPassedInTestDeck: [Flashcard]?
    private(set) var repeatDeck: [Flashcard]?
    private(set) var currentCard: Flashcard?
    private var passedFlashcards = 0
    var index = 1
    private var numberOfFlashcardsInFullDeck: Int
    let testType: StudyType
    private var cardsInTest: Int = 0
    //last 2 properties are amde to determinate if passed deck was empty from the beginning or if all flashcards was hidden
    private(set) var allFlashcardsHidden: Bool = false
    private(set) var passedDeckWasEmpty: Bool = false
    
    init(flashcards: [Flashcard], testType: StudyType, deck: Deck) {
        
        self.deck = deck
        passedDeckWasEmpty = flashcards.isEmpty
        
        //Making a temporary deck with only not hidden flashcards
        var tmpDeck: [Flashcard] = []
        for flashcard in flashcards {
            if flashcard.hidden == false {
                tmpDeck.append(flashcard)
            }
        }
        
        switch testType {
        case .Learn:
            self.flashcards = tmpDeck.shuffle()
            cardsInTest = self.flashcards.count
            repeatDeck = self.flashcards
        case .Test(let questionsNumber):
            notPassedInTestDeck = [Flashcard]()
            self.flashcards = tmpDeck.shuffle(maxElements: Int(questionsNumber))
            cardsInTest = self.flashcards.count
        }

        self.numberOfFlashcardsInFullDeck = self.flashcards.count
        self.testType = testType
        
        //This parameter helps function to determinate if all flashcards in passed deck are hidden.
        allFlashcardsHidden = numberOfFlashcardsInFullDeck == 0 && passedDeckWasEmpty == false
        
        newFlashcard()
    }
    
//    Returns a tuple of numbers of flashcards that were answered correctly and how many flashcards are in the test
//     - returns: `(passedFlashcards,cardsInTest)`
    func cardsAnsweredAndPossible() -> (Int, Int) {
        return (passedFlashcards, cardsInTest)
    }
    
//    Sets new flashcard and depending on `answeredCorrect` moves the card to end of deck
//     - Parameter answeredCorrect: Was the last card marked correct or not
//     - returns: Newly set `Flashcard?`; `nil` if no new `Flashcard` is there to set
    private func setFlashcardStatus(answeredCorrect answeredCorrect: Bool) {
        if !answeredCorrect{
            switch testType{
            case .Learn:
                //moves card to end of deck, if currentCard is not nil
                if let moveCardToEnd = currentCard {
                    flashcards.append(moveCardToEnd)
                }
            case .Test:
                index += 1
                if let cardForTestRepeat = currentCard {
                    notPassedInTestDeck?.append(cardForTestRepeat)
                }
                break
            }
        } else {
            index += 1
        }
    }
    
    //Returns new 'Flashcard?' or nil if there's no Flashcard to set
    private func newFlashcard() -> Flashcard? {
        if !flashcards.isEmpty {
            currentCard = flashcards.first
            flashcards.removeFirst()
        } else {
            currentCard = nil
        }
        return currentCard
    }
    
    //Function to call when user taps "correct" button, sets a new flashcard and increments `passedFlashcards`
    func correctAnswer() -> Flashcard? {
        passedFlashcards += 1
        setFlashcardStatus(answeredCorrect:true)
        return newFlashcard()
    }
    
    //Function to call when user taps "incorrect" button, and moves `currentCard` to end of deck
    func incorrectAnswer() -> Flashcard? {
        setFlashcardStatus(answeredCorrect:false)
        return newFlashcard()
    }

    //Function skips currentCard to end of deck
    func skipCard() -> Flashcard? {
        if let skipCard = currentCard {
            flashcards.append(skipCard)
        }
        return newFlashcard()
    }
}
