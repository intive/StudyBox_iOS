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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        
        super.tearDown()
    }

    func testCheckIfAllFlashcardsHidden() {
        // checking if true
        var mockData = MockData(amount: 1, hidden: 1)
        var testLogic = Test(deck: mockData.flashcardArray, testType: .Learn)
        
        XCTAssertTrue(testLogic.checkIfAllFlashcardsHidden(), "Initialized with 1 deck, Learn mode and all hidden, checkIfAllFlashcardsHidden should be true")
        
        testLogic = Test(deck: mockData.flashcardArray, testType: .Test(1))
        
        XCTAssertTrue(testLogic.checkIfAllFlashcardsHidden(), "Initialized with 1 deck, Test mode and all hidden, checkIfAllFlashcardsHidden should be true")
        
        mockData = MockData(amount: MockData.notOneNumber, hidden: MockData.notOneNumber)
        testLogic = Test(deck: mockData.flashcardArray, testType: .Learn)
        
        XCTAssertTrue(testLogic.checkIfAllFlashcardsHidden(), "Initialized with \(MockData.notOneNumber) deck(s), Learn mode and all hidden, checkIfAllFlashcardsHidden should be true")
        
        testLogic = Test(deck: mockData.flashcardArray, testType: .Test(1))
        
        XCTAssertTrue(testLogic.checkIfAllFlashcardsHidden(), "Initialized with \(MockData.notOneNumber) deck(s), Test mode and all hidden, checkIfAllFlashcardsHidden should be true")
        
        // checking if false
        mockData = MockData(amount: 1, hidden: 0)
        testLogic = Test(deck: mockData.flashcardArray, testType: .Learn)
        
        XCTAssertFalse(testLogic.checkIfAllFlashcardsHidden(), "Initialized with 1 deck(s), Learn mode and no hidden, checkIfAllFlashcardsHidden should be false")
        
        testLogic = Test(deck: mockData.flashcardArray, testType: .Test(1))
        
        XCTAssertEqual(1, testLogic.cardsAnsweredAndPossible().1, "There should be only one card in test")
        
        XCTAssertFalse(testLogic.checkIfAllFlashcardsHidden(), "Initialized with 1 deck(s), Test mode and no hidden, checkIfAllFlashcardsHidden should be false")
        
        mockData = MockData(amount: MockData.notOneNumber, hidden: 1)
        testLogic = Test(deck: mockData.flashcardArray, testType: .Learn)
        
        XCTAssertFalse(testLogic.checkIfAllFlashcardsHidden(), "Initialized with \(MockData.notOneNumber) deck(s), Learn mode and 1 hidden, checkIfAllFlashcardsHidden should be false")
        
        testLogic = Test(deck: mockData.flashcardArray, testType: .Test(1))
        
        XCTAssertEqual(1, testLogic.cardsAnsweredAndPossible().1, "There should be only one card in test")
        
        XCTAssertFalse(testLogic.checkIfAllFlashcardsHidden(), "Initialized with \(MockData.notOneNumber) deck(s), Test mode and 1 hidden, checkIfAllFlashcardsHidden should be false")
    }
    
    func testCheckIfPassedDeckIsEmpty() {
        // checking if returning true
        var testLogic = Test(deck: [], testType: .Learn)
        
        XCTAssertTrue(testLogic.checkIfPassedDeckIsEmpty(), "Initialized with empty Flashcard array and Learn mode, passedDeckWasEmpty should be true")
        
        testLogic = Test(deck: [], testType: .Test(1))
        
        XCTAssertEqual(0, testLogic.cardsAnsweredAndPossible().1, "There should not be any card int test")
        XCTAssertTrue(testLogic.checkIfPassedDeckIsEmpty(), "Initialized with empty Flashcard array and Test mode, passedDeckWasEmpty should be true")
        
        // checking if returning false
        let mockData = MockData(amount: 1)
        testLogic = Test(deck: mockData.flashcardArray, testType: .Learn)
        
        XCTAssertFalse(testLogic.checkIfPassedDeckIsEmpty(), "Initialized with not empty Flashcard array, passedDeckWasEmpty should be false")
        
        testLogic = Test(deck: mockData.flashcardArray, testType: .Test(1))
        
        XCTAssertEqual(1, testLogic.cardsAnsweredAndPossible().1, "There should not be any card int test")
        
        XCTAssertFalse(testLogic.checkIfPassedDeckIsEmpty(), "Initialized with not empty Flashcard array and Test mode, passedDeckWasEmpty should be false")
    }
    
    func testCorrectAnswer() {
        // should return nil, empty array
        var testLogic = Test(deck: [], testType: .Learn)
        
        XCTAssertNil(testLogic.correctAnswer(), "No flashcards in deck, correctAnswer should resturn nil")
        XCTAssertEqual(testLogic.index, 1, "index should be increased, after correctAnswer")
        
        var mockData = MockData(amount: 1)
        testLogic = Test(deck: mockData.flashcardArray, testType: .Learn)
        
        XCTAssertNil(testLogic.correctAnswer(), "Only one flashcard in deck, correctAnswer should resturn nil")
        XCTAssertEqual(testLogic.index, 1, "index should be increased, after correctAnswer")
        
        // not nil
        mockData = MockData(amount: MockData.notOneNumber)
        testLogic = Test(deck: mockData.flashcardArray, testType: .Learn)
        
        XCTAssertNotNil(testLogic.correctAnswer(), "\(MockData.notOneNumber) flashcards in deck, correctAnswer should return not nil object")
        XCTAssertEqual(testLogic.index, 1, "index should be increased, after correctAnswer")
        
        for _ in 2...MockData.notOneNumber {
            testLogic.correctAnswer()
        }
        
        XCTAssertEqual(testLogic.index, MockData.notOneNumber, "index should be equal \(MockData.notOneNumber)")
        
        // test from 10 decks
        mockData = MockData(amount: 10)
        testLogic = Test(deck: mockData.flashcardArray, testType: .Test(10))
        
        XCTAssertEqual(10, testLogic.cardsAnsweredAndPossible().1, "There should be 10 cards in test")
        
        for _ in 1...9 {
            XCTAssertNotNil(testLogic.correctAnswer(), "Only last correctAnswer call should return nil")
        }
        
        XCTAssertNil(testLogic.correctAnswer(), "Only last correctAnswer call should return nil")
        
        let passed = testLogic.cardsAnsweredAndPossible().0
        
        XCTAssertEqual(passed, 10, "Passed cards should be equal 10")
    }
    
    func testIncorrectAnswer() {
        // should return nil, empty array
        var testLogic = Test(deck: [], testType: .Learn)
        
        XCTAssertNil(testLogic.incorrectAnswer(), "No flashcards in deck, incorrectAnswer should resturn nil")
        XCTAssertEqual(testLogic.index, 0, "index should not be increased, after incorrectAnswer in Learn mode")
        
        // one flashcard, Learn mode
        var mockData = MockData(amount: 1)
        let givenFlashcard = mockData.flashcardArray.last!
        testLogic = Test(deck: mockData.flashcardArray, testType: .Learn)
        let result = testLogic.incorrectAnswer()
        
        XCTAssertNotNil(result, "Deck not empty, incorrectAnswer should return next flashcard")
        XCTAssertTrue(result === givenFlashcard, "One flashcard in deck, incorrectAnswer in Learn mode should return the same object")
        
        // few flashcards, Learn mode
        mockData = MockData(amount: 2)
        testLogic = Test(deck: mockData.flashcardArray, testType: .Learn)
        
        let second = testLogic.incorrectAnswer()
        let first = testLogic.incorrectAnswer()
        
        XCTAssertNotNil(first, "Deck not empty, incorrectAnswer should return next flashcard")
        XCTAssertFalse(first === second, "Two flashcards in deck, incorrectAnswer in Learn mode should return diffrent objects")
 
        // test from one flashcard, Test mode
        mockData = MockData(amount: 1)
        testLogic = Test(deck: mockData.flashcardArray, testType: .Test(1))
        
        XCTAssertNil(testLogic.incorrectAnswer(), "Test from one flashcard, incorrectAnswer should resturn nil")
        
        mockData = MockData(amount: MockData.notOneNumber)
        testLogic = Test(deck: mockData.flashcardArray, testType: .Test(1))
        
        XCTAssertEqual(1, testLogic.cardsAnsweredAndPossible().1, "There should be only one card in test")
        XCTAssertNil(testLogic.incorrectAnswer(), "Test from one flashcard, incorrectAnswer should resturn nil")

    }
    
    func testSkipCard() {
        // should return nil, empty array
        var testLogic = Test(deck: [], testType: .Learn)
        
        XCTAssertNil(testLogic.skipCard(), "No flashcards in deck, skipCard should resturn nil")
        
        // should return nil, empty array
        let mockData = MockData(amount: 1)
        testLogic = Test(deck: mockData.flashcardArray, testType: .Learn)
        let skipped = testLogic.skipCard()
        
        XCTAssertTrue(skipped === testLogic.skipCard(), "No flashcards in deck, skipCard should resturn nil")
    }
    
    class MockData {
        var flashcardArray = [Flashcard]()
        static let notOneNumber = 10
        
        init(amount: Int, hidden: Int = 0) {
            var hiddenNumber = (hidden > amount) ? amount : hidden;
            
            for _ in 1...amount {
                let current = Flashcard(serverID: "serverID", deckId: "deckID", question: "question", answer: "answer", tip: Tip.Text(text: "Tip"))
                
                if hiddenNumber > 0 {
                    current.hidden = true
                    hiddenNumber = hiddenNumber - 1
                }
                
                flashcardArray.append(current)
            }
        }
    }
    
}
