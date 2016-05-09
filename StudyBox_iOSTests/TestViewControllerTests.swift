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
    func testAnswerViewShouldBeHiddenWhenStart() {
        XCTAssertFalse(sut.answerTrailing.active)
    }
    
    func testQuestionViewShouldBeVisibleWhenStart() {
        XCTAssertEqual(sut.questionView.alpha, 1)
    }
    
    func testShouldPerformSegueWithIdentifier_shouldDisplayAlertIfScoreSequeAndLern() {
        sut.pushDummyData(.Learn)
        
        sut.shouldPerformSegueWithIdentifier("SthElse", sender: self)
        XCTAssertFalse(sut.presentedViewController is UIAlertController)
        
        sut.shouldPerformSegueWithIdentifier("ScoreSegue", sender: self)
        XCTAssertTrue(sut.presentedViewController is UIAlertController)
    }
    
    func testShouldPerformSegueWithIdentifier_shouldNotDisplayAlertIfScoreSequeAndLearn() {
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
    
    func testSwipedUpShouldChangeQuestionAnswer() {
        /*
            testing in
            updateQuestionUiForCurrentCard
            updateAnswerUiForCurrentCard
        */
    }
    
    func testShowTipShouldNotDisplayTipIfDeckEmpty() {
        sut.showTip(self)
        XCTAssertTrue(sut.presentedViewController is UIAlertController)
        let message = sut.presentedViewController as! UIAlertController
        XCTAssertEqual(message.message, "Brak podpowiedzi")
    }

    func testShowTipShouldDisplayTipIfDeckNotEmpty() {
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
        XCTAssertTrue(sut.scoreLabel.text?.rangeOfString("[0-9]+ / [0-9]+", options: .RegularExpressionSearch) != nil)
    }
    
    func testUpdateAnswerUiForCurrentCard_shouldUpdateAnswerLabelAndCurrentQuestionNumber() {
        sut.pushDummyData(.Learn)
        sut.updateAnswerUiForCurrentCard()
        XCTAssertEqual(sut.answerLabel.text, sut.testLogicSource?.currentCard?.answer)
        XCTAssertTrue(sut.currentQuestionNumber.text?.rangeOfString("#[0-9]+", options: .RegularExpressionSearch) != nil)
    }
    
    func testUpdateForAnswer_shouldCallAnsweredQuestionTransitionMethod() {
        let sut = mockTestViewController()
        sut.testLogicSource = Test(deck: [], testType: .Learn)
        sut.pushDummyData(.Learn)
        sut.updateForAnswer(false)
        XCTAssertTrue(sut.wasOpened)
    }
    /*
    func testUpdateForAnswer_shouldPerformSegueWhenDeckIsEmpty() {
        sut.testLogicSource = Test(deck: [], testType: .Test(1))
        sut.updateForAnswer(true)
        print("view??: \(sut.nibName)")
        XCTAssertTrue(true)
    }
    */
    func testIfDeskIsEmptyShouldCall_displayAlertIfPassedDeskIsEmpty() {
        let sut = mockTestViewController()
        //desk is empty!
        sut.testLogicSource = Test(deck: [], testType: .Learn)
        sut.displayAlertIfPassedDeskIsEmpty()
        XCTAssertTrue(sut.wasOpened)
    }
    
    func testIfDeskIsEmptyShouldNotCall_displayAlertIfPassedDeskIsEmpty() {
        let sut = mockTestViewController()
        sut.pushDummyData(.Learn)
        sut.displayAlertIfPassedDeskIsEmpty()
        
        XCTAssertFalse(sut.wasOpened)
    }
    
    func testIfDeckIsEmptyShouldCallAlert() {
        sut.testLogicSource = Test(deck: [], testType: .Learn)
        sut.displayAlertIfPassedDeskIsEmpty()
        XCTAssertNotNil(sut.view)
        XCTAssertTrue(sut.presentedViewController is UIAlertController)
    }

    func testIfDeckIsEmptyShouldNotCallIfNotHidden_displayAlertIfPassedDeskHasAllFlashcardsHidden() {
        let sut = mockTestViewController()
        sut.pushDummyData(.Learn, allHidden: false)
        
        sut.displayAlertIfPassedDeskHasAllFlashcardsHidden()
        XCTAssertFalse(sut.wasOpened)
    }
    
    func testIfDeckIsEmptyShouldCall_displayAlertIfPassedDeskHasAllFlashcardsHidden() {
        let sut = mockTestViewController()
        sut.pushDummyData(.Learn, allHidden: true)

        sut.displayAlertIfPassedDeskHasAllFlashcardsHidden()
        XCTAssertTrue(sut.wasOpened)
    }
    
    func testIfCallAlertIfDeckIsEmpty() {
        sut.pushDummyData(.Learn, allHidden: true)
        sut.displayAlertIfPassedDeskHasAllFlashcardsHidden()
        XCTAssertTrue(sut.presentedViewController is UIAlertController)
    }

}


extension TestViewControllerTests {
    class mockTestViewController: TestViewController {
        var passedFlashcards = 0
        var wasOpened = false
 
        override func displayAlertIfPassedDeskIsEmpty() {
            if (testLogicSource?.checkIfPassedDeckIsEmpty()) == true {
                wasOpened = true
            }
        }
        override func answeredQuestionTransition() {
            wasOpened = true
        }
        override func displayAlertIfPassedDeskHasAllFlashcardsHidden() {
            if testLogicSource?.checkIfAllFlashcardsHidden() == true {
                wasOpened = true
            }
        }
    }
}
extension TestViewController {
    func pushDummyData(testType: StudyType, allHidden: Bool = false) {
        let flashcard = Flashcard(serverID: "a", deckId: "a", question: "a", answer: "a", tip: Tip.Text(text: "a"))
        var flashcardArray = [flashcard]
        for _ in 1...10 {
            if allHidden {
                flashcard.hidden = true
            }
            flashcardArray.append(flashcard)
        }
        testLogicSource = Test(deck: flashcardArray, testType: testType)
    }
}
