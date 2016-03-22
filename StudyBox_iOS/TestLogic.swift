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
    private var deck : [Flashcard]
    private(set) var notPassedInTestDeck: [Flashcard]?
    private(set) var repeatDeck:[Flashcard]?
    private(set) var currentCard : Flashcard?
    private var passedFlashcards = 0
    private var index = 0
    private var numberOfFlashcardsInFullDeck : Int
    let testType : StudyType
    private let cardsInTest : Int
    
    init(deck : [Flashcard], testType : StudyType) {
        self.deck = deck
        self.numberOfFlashcardsInFullDeck = deck.count
        self.testType = testType
        
        switch testType {
        case .Learn:
            cardsInTest = deck.count
            repeatDeck = deck
        case .Test(let questionsNumber):
            notPassedInTestDeck = [Flashcard]()
            if questionsNumber > uint(deck.count) {
                cardsInTest = deck.count
            } else {
                cardsInTest = Int(questionsNumber)
            }
        }
        
        newFlashcard(answeredCorrect:true)
    }
    
    /** Returns a tuple of numbers of flashcards that were answered correctly and how many flashcards are in the test
     - returns: `(passedFlashcards,cardsInTest)`
     */
    func cardsAnsweredAndPossible() -> (Int,Int) {
        return (passedFlashcards,cardsInTest)
    }
    
    /** Sets new flashcard and depending on `answeredCorrect` moves the card to end of deck
     - Parameter answeredCorrect: Was the last card marked correct or not
     - returns: Newly set `Flashcard?`; `nil` if no new `Flashcard` is there to set
     */
    func newFlashcard(answeredCorrect answeredCorrect:Bool) -> Flashcard? {
        var rand : Int
        
        if !answeredCorrect{
            switch testType{
            case .Learn:
                //moves card to end of deck, if currentCard is not nil
                if let moveCardToEnd = currentCard {
                    deck.append(moveCardToEnd)
                }
            case .Test(uint(cardsInTest)):
                index += 1
                if let cardForTestRepeat = currentCard {
                    notPassedInTestDeck?.append(cardForTestRepeat)
                }
                break
            default:
                break
            }
        }else {
            index += 1
        }
        rand = Int(arc4random_uniform(UInt32(deck.count)))
        if rand < deck.count && cardsInTest + 1 > index {
            currentCard = deck[rand]
            deck.removeAtIndex(rand)
        }else {
            currentCard = nil
        }
        return currentCard
    }
    
    ///Function to call when user taps "correct" button, sets a new flashcard and increments `passedFlashcards`
    func correctAnswer()->Flashcard? {
        passedFlashcards += 1
        return newFlashcard(answeredCorrect:true)
    }
    
    ///Function to call when user taps "incorrect" button, and moves `currentCard` to end of deck
    func incorrectAnswer()->Flashcard? {
        return newFlashcard(answeredCorrect:false)
    }
}