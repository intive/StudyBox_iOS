//
//  TestLogic.swift
//  StudyBox_iOS
//
//  Created by user on 12.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

enum NumberOfQuestions {
    
    case Test(uint), Learn
}

class Test {
    
    private var deck : [Flashcard]
    private var currentCard : Flashcard?
    private var passedFlashcards = 0
    private var index = 0
    private var numberOfFlashcardsInFullDeck : Int
    private let testType : NumberOfQuestions
    private let cardsInTest : Int
    
    init(deck : [Flashcard], testType : NumberOfQuestions) {
        
        self.deck = deck
        self.numberOfFlashcardsInFullDeck = deck.count
        self.testType = testType
        
        switch testType {
        case .Learn:
            cardsInTest = deck.count
        case .Test(let questionsNumber):
            if questionsNumber > uint(deck.count) {
                cardsInTest = deck.count
            } else {
                cardsInTest = Int(questionsNumber)
            }
        }
        currentFlashcard()
    }
    
    func currentFlashcard() {
        
        var rand : Int
        
        if(cardsInTest == index) {
            
            currentCard = nil
        }
        else {
            
            rand = Int(arc4random_uniform(UInt32(deck.count)))
            currentCard = deck[rand]
            deck.removeAtIndex(rand)
            index += 1
        }
    }
    
    func correctAnswer() { //funkcja podpieta pod przycisk dobra odpowiedz
        
        passedFlashcards += 1
        currentFlashcard()
    }
    
    func IncorrectAnswer() {   //funkcja podpieta pod przycisk zla odpowiedz
        
        currentFlashcard()
    }
}