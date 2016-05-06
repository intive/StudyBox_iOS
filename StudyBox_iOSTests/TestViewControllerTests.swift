//
//  TestViewControllerTests.swift
//  StudyBox_iOS
//
//  Created by Piotr Rudnicki on 04.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import XCTest
import UIKit
@testable import StudyBox_iOS

class TestViewControllerTests: XCTestCase {
    var sut: TestViewController!
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewControllerWithIdentifier("TestViewControllerID") as! TestViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController = sut
        _ = sut.view
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //based on NSLayoutConstraint in answerView -> False on start!
    func testAnswerViewShoudBeHiddenWhenStart() {
        XCTAssertFalse(sut.answerTrailing.active)
    }
    
    //??
    func testQuestionViewShoudBeVisibleWhenStart() {
        XCTAssertEqual(sut.questionView.alpha, 1)
    }
    
    func testShouldPerformSegueWithIdentifier_shoudDisplayAlertIfScoreSequeAndLern() {
        sut.pushDummyData(.Learn)
        
        sut.shouldPerformSegueWithIdentifier("SthElse", sender: self)
        XCTAssertFalse(sut.presentedViewController is UIAlertController)
        
        sut.shouldPerformSegueWithIdentifier("ScoreSegue", sender: self)
        XCTAssertTrue(sut.presentedViewController is UIAlertController)
    }
    
    func testShouldPerformSegueWithIdentifier_shoudNotDisplayAlertIfScoreSequeAndLern() {
        sut.pushDummyData(.Test(1))
        
        sut.shouldPerformSegueWithIdentifier("SthElse", sender: self)
        XCTAssertFalse(sut.presentedViewController is UIAlertController)
        
        sut.shouldPerformSegueWithIdentifier("ScoreSegue", sender: self)
        XCTAssertFalse(sut.presentedViewController is UIAlertController)
    }
    

    
    func testQuestionViewHiddenAnswerViewVisibleSwipeLeft() {
        sut.swipedLeft()
        XCTAssertTrue(sut.answerTrailing.active)
        
        //questionView outside the screen
        let questionViewRightSidePosition = sut.questionView.center.x + (sut.questionView.frame.size.width/2)
        XCTAssertTrue(questionViewRightSidePosition < 0)
    }
    
    func testSwipedUpShoudChangeQuestionAnswer() {
        /*
            testing in
            updateQuestionUiForCurrentCard
            updateAnswerUiForCurrentCard
        */
    }
    
    func testShowTipShoudNotDisplayTipIfDeckEmpty() {
        sut.showTip(self)
        XCTAssertTrue(sut.presentedViewController is UIAlertController)
        let message = sut.presentedViewController as! UIAlertController
        XCTAssertEqual(message.message, "Brak podpowiedzi")
    }

    func testShowTipShoudDisplayTipIfDeckNotEmpty() {
        sut.pushDummyData(.Learn)
        sut.showTip(self)
        let message = sut.presentedViewController as! UIAlertController
        XCTAssertEqual(message.message, sut.testLogicSource?.currentCard?.tip)
    }
    
    func testUpdateQuestionUiForCurrentCard_shouldUpdateQuestionLabel() {
        sut.pushDummyData(.Learn)
        XCTAssertNotEqual(sut.questionLabel.text, sut.testLogicSource?.currentCard?.question)
        
        sut.updateQuestionUiForCurrentCard()
        XCTAssertEqual(sut.questionLabel.text, sut.testLogicSource?.currentCard?.question)
    }

    func testUpdateQuestionUiForCurrentCard_shouldUpdateScoreLabel() {
        sut.pushDummyData(.Learn)
        let currentScoreLabel = sut.scoreLabel.text
        sut.updateQuestionUiForCurrentCard()
        XCTAssertNotEqual(currentScoreLabel, sut.scoreLabel.text)
    }
    
    func testUpdateAnswerUiForCurrentCard_shouldUpdateAnswerLabelAndCurrentQuestionNumber() {
        sut.pushDummyData(.Learn)
        let currentAnswerLabel = sut.answerLabel
        let currentQuestionNumer = sut.currentQuestionNumber
        print("\n\n\n1: \(sut.currentQuestionNumber) + \(sut.answerLabel)\n\n\n")
        sut.updateAnswerUiForCurrentCard()
        sut.updateAnswerUiForCurrentCard()
        print("\n\n\n2: \(sut.currentQuestionNumber) + \(sut.answerLabel) \n\n\n")
        XCTAssertNotEqual(currentAnswerLabel, sut.answerView)
        XCTAssertNotEqual(currentQuestionNumer, sut.currentQuestionNumber)
    }
    
    func testIfDeskIsEmptyShoudCall_displayAlertIfPassedDeskIsEmpty() {
        let sut = mockTestViewController()
        //desk is empty!
        sut.testLogicSource = Test(deck: [], testType: .Learn)
        sut.displayAlertIfPassedDeskIsEmpty()
        XCTAssertTrue(sut.wasOpened)
    }
    
    func testIfDeskIsEmptyShoudNotCall_displayAlertIfPassedDeskIsEmpty() {
        let sut = mockTestViewController()
        sut.pushDummyData(.Learn)
        sut.displayAlertIfPassedDeskIsEmpty()
        
        XCTAssertFalse(sut.wasOpened)
    }
    
    func testIfDeckIsEmptyShoudCallAlert() {
        sut.testLogicSource = Test(deck: [], testType: .Learn)
        sut.displayAlertIfPassedDeskIsEmpty()
        XCTAssertNotNil(sut.view)
        XCTAssertTrue(sut.presentedViewController is UIAlertController)
    }
    
}
extension TestViewControllerTests {
    class mockTestViewController: TestViewController {
        var wasOpened = false
 
        override func displayAlertIfPassedDeskIsEmpty() {
            if (testLogicSource?.checkIfPassedDeckIsEmpty()) == true {
                wasOpened = true
            }
        }
    }
}
extension TestViewController {
    func pushDummyData(testType: StudyType) {
        let flashcard = Flashcard(serverID: "a", deckId: "a", question: "a", answer: "a", tip: Tip.Text(text: "a"))
        var flashcardArray = [flashcard]
        for _ in 1...10 {
            flashcardArray.append(flashcard)
            }
        testLogicSource = Test(deck: [flashcard], testType: testType)
    }
}
