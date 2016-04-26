//
//  TestLogicTests.swift
//  StudyBox_iOS
//
//  Created by Piotr Zielinski on 25.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import XCTest
@testable import StudyBox_iOS

class TestLogicTests: XCTestCase {
    
    // number of flashcards in array. Bigger than one
    let flashcardsNumber = 10
    let flashcard = Flashcard(serverID: "serverID", deckId: "deckID", question: "question", answer: "answer", tip: Tip.Text(text: "Tip"))
    
// checkIfAllFlashcardsHidden()
    
    func testCheckIfAllFlashcardsHiddenWithAllHiddenFlashcards() {
        // prepare
        let mockData = flashcardsArray(amount: flashcardsNumber, hidden: flashcardsNumber)
        let testLogic = Test(deck: mockData, testType: .Learn)
        
        // do
        let result = testLogic.checkIfAllFlashcardsHidden()
        
        // check
        XCTAssertTrue(result, "Initialized with all hidden flashcards, method should return True")
    }
    
    func testCheckIfAllFlashcardsHiddenWithNoHiddenFlashcards() {
        // prepare
        let mockData = flashcardsArray(amount: flashcardsNumber)
        let testLogic = Test(deck: mockData, testType: .Learn)
        
        // do
        let result = testLogic.checkIfAllFlashcardsHidden()
        
        // check
        XCTAssertFalse(result, "Initialized with not hidden flashcards, method should return False")
    }
    
// checkIfPassedDeckIsEmpty()
    
    func testCheckIfPassedDeckIsEmptyWithNoFlashcards() {
        // prepare
        let testLogic = Test(deck: [], testType: .Learn)
        
        // do
        let result = testLogic.checkIfPassedDeckIsEmpty()
        
        // check
        XCTAssertTrue(result, "Initialized with empty Flashcard array, passedDeckWasEmpty should be true")
    }
    
    func testCheckIfPassedDeckIsEmptyWithMoreThanOneFlashcard() {
        // prepare
        let mockData = flashcardsArray(amount: flashcardsNumber)
        let testLogic = Test(deck: mockData, testType: .Learn)
        
        // do
        let result = testLogic.checkIfPassedDeckIsEmpty()
        
        // check
        XCTAssertFalse(result, "Initialized with not empty Flashcard array, passedDeckWasEmpty should be false")
    }
    
// correctAnswer()
    
    func testCorrectAnswerWithNoFlashcards() {
        // prepare
        let testLogic = Test(deck: [], testType: .Learn)
        let passed = testLogic.cardsAnsweredAndPossible().0
        
        // do
        let result = testLogic.correctAnswer()
        
        // check
        XCTAssertNil(result, "No flashcards in deck, correctAnswer should resturn nil in Learn mode")
        XCTAssertTrue((testLogic.cardsAnsweredAndPossible().0 - passed) == 1, "passedFlashcard should be increased by one ")
    }
    
    func testCorrectAnswerWithOneFlashcard() {
        // prepare
        let mockData = flashcardsArray(amount: 1)
        let testLogic = Test(deck: mockData, testType: .Learn)
        let passed = testLogic.cardsAnsweredAndPossible().0
        
        // do
        let result = testLogic.correctAnswer()
        
        // check
        XCTAssertNil(result, "One flashcard in deck, correctAnswer should resturn nil in Learn mode")
        XCTAssertTrue((testLogic.cardsAnsweredAndPossible().0 - passed) == 1, "passedFlashcard should be increased by one ")
    }
    
    func testCorrectAnswerWithMoreThanOneFlashcard() {
        // prepare
        let mockData = flashcardsArray(amount: flashcardsNumber)
        let testLogic = Test(deck: mockData, testType: .Learn)
        
        // do
        var result: Flashcard?
        for _ in 1...flashcardsNumber-1 {
            result = testLogic.correctAnswer()
            XCTAssertNotNil(result, "All except last calls sshould return not nil object")
        }
        result = testLogic.correctAnswer()
        
        // check
        XCTAssertNil(result, "One flashcard in deck, correctAnswer should return nil in Learn mode")
        XCTAssertTrue(testLogic.cardsAnsweredAndPossible().0 == flashcardsNumber, "passedFlashcard should be increased by one ")
    }
    
// incorrectAnswer()
    
    func testIncorrectAnswerWithNoFlashcards() {
        // prepare
        let testLogic = Test(deck: [], testType: .Learn)
        
        // do
        let result = testLogic.incorrectAnswer()
        
        // check
        XCTAssertNil(result, "No flashcards in deck, incorrectAnswer should return nil")
    }
    
    func testIncorrectAnswerWithOneFlashcardInLearnMode() {
        // prepare
        let testLogic = Test(deck: [flashcard], testType: .Learn)
        
        // do
        let result = testLogic.incorrectAnswer()
        
        // check
        XCTAssertTrue(result === flashcard, "One flashcard in deck, incorrectAnswer in Learn mode should return the same object")
    }
    
    func testIncorrectAnswerWithTwoFlashcardsInLearnMode() {
        // prepare
        let mockData = flashcardsArray(amount: 2)
        let testLogic = Test(deck: mockData, testType: .Learn)
        
        // do
        let second = testLogic.incorrectAnswer()!
        let first = testLogic.incorrectAnswer()!
        
        // check
        XCTAssertFalse(first === second, "Two flashcards in deck, incorrectAnswer in Learn mode should return diffrent objects")
    }
    
    func testIncorrectAnswerWithOneFlashcardInTestMode() {
        // prepare
        let testLogic = Test(deck: [flashcard], testType: .Test(1))
        
        // do
        let result = testLogic.incorrectAnswer()
        
        // check
        XCTAssertNil(result, "One flashcard in deck, incorrectAnswer should return nil in Test Mode")
    }
    
    func testIncorrectAnswerWithMoreThanOneFlashcardInTestMode() {
        // prepare
        let mockData = flashcardsArray(amount: flashcardsNumber)
        let testLogic = Test(deck: mockData, testType: .Test(uint(flashcardsNumber)))
        
        // do
        var result: Flashcard?
        for _ in 1...flashcardsNumber-1 {
            result = testLogic.incorrectAnswer()
            XCTAssertNotNil(result, "All except last calls should return not nil object")
        }
        result = testLogic.incorrectAnswer()
        
        // check
        XCTAssertNil(result, "Last incorrectAnswer from original deck should return nil")
    }
    
// skipCard()
    
    func testSkipCardWithNoFlashcards() {
        // prepare
        let testLogic = Test(deck: [], testType: .Learn)
        
        // do
        let result = testLogic.skipCard()
        
        // check
        XCTAssertNil(result, "No flashcards in deck, skipCard should return nil")
    }
    
    func testSkipCardWithOneFlashcard() {
        // prepare
        let testLogic = Test(deck: [flashcard], testType: .Learn)
        
        // do
        let result = testLogic.skipCard()!
        
        // check
        XCTAssertNotNil(result, "One flashcard in deck, skipCard should return not nil object")
        XCTAssertTrue(flashcard === result, "Returned flashcard should be the same object")
    }
    
    func testSkipCardWithMoreThanOneFlashcard() {
        // prepare
        let mockData = flashcardsArray(amount: flashcardsNumber)
        let testLogic = Test(deck: mockData, testType: .Learn)
        
        // do
        let result = testLogic.skipCard()
        
        // check
        XCTAssertNotNil(result, "More than one flashcard in deck, skipCard should return not nil object")
    }
    
    func flashcardsArray(amount amount: Int, hidden: Int = 0) -> [Flashcard] {
        var flashcardArray = [Flashcard]()
        var hiddenNumber = (hidden > amount) ? amount : hidden;
        
        for _ in 1...amount {
            let current = Flashcard(serverID: "serverID", deckId: "deckID", question: "question", answer: "answer", tip: Tip.Text(text: "Tip"))
            
            if hiddenNumber > 0 {
                current.hidden = true
                hiddenNumber = hiddenNumber - 1
            }
            
            flashcardArray.append(current)
        }
        
        return flashcardArray
    }
    
}

