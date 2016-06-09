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
        let window = UIWindow()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewControllerWithIdentifier("TestViewControllerID") as! TestViewController
        _ = sut.view
        
        //add TestViewController to view hierarchy
        window.addSubview(sut.view)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //based on NSLayoutConstraint in answerView -> False on start!
    func testAnswerViewShouldBeHiddenWhenStart() {
        XCTAssertFalse(sut.answerTrailing.active, "AnswerTrailing should not be active on start -> should be hidden")
    }
    
    func testQuestionViewShouldBeVisibleWhenStart() {
        XCTAssertEqual(sut.questionView.alpha, 1, "QuestionView should be visible on start")
    }
    
    func testShouldDisplayAlertIfScoreSequeAndLearn() {
        sut.pushDummyData(.Learn)
        
        sut.shouldPerformSegueWithIdentifier("SthElse", sender: self)
        XCTAssertFalse(sut.presentedViewController is UIAlertController, "Should not display alert if segue is not ScoreSegue")
        
        sut.shouldPerformSegueWithIdentifier("ScoreSegue", sender: self)
        XCTAssertTrue(sut.presentedViewController is UIAlertController, "Should display alert if segue is ScoreSegue")
    }
    
    func testShouldNotDisplayAlertIfScoreSequeAndLearn() {
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
        XCTAssertTrue(questionViewRightSidePosition < 0, "QuestionView should be outside the screen")
    }
    
    func testSwipedUpShouldChangeQuestionAnswer() {
        /*
            testing in
            updateQuestionUiForCurrentCard
            updateAnswerUiForCurrentCard
        */
    }
    
    func testShouldUpdateQuestionLabel() {
        sut.pushDummyData(.Learn)
        XCTAssertNotEqual(sut.questionLabel.text, sut.testLogicSource?.currentCard?.question, "Shouldn't display question on start, before update screen")
        
        sut.updateQuestionUiForCurrentCard()
        XCTAssertEqual(sut.questionLabel.text, sut.testLogicSource?.currentCard?.question, "Should display correct question")
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
        sut.testLogicSource = Test(flashcards: [], testType: .Learn, deck: Deck())
        sut.pushDummyData(.Learn)
        sut.updateForAnswer(false)
        XCTAssertTrue(sut.wasOpened)
    }

    func testCorrectButtonTouchShouldScaleWhenPressed() {
        testButtonSizeShouldBeEqualAfterTransform(sut.correctButton, controlEventOne: .TouchDown, controlEventTwo: nil, resize: 0.85)
    }
    
    func testCorrectButtonTouchDragExitShouldGetNormalSize() {
        testButtonSizeShouldBeEqualAfterTransform(sut.correctButton, controlEventOne: .TouchDown, controlEventTwo: .TouchDragExit, resize: nil)
    }

    func testCorrectButtonTouchCancelShouldGetNormalSize() {
        testButtonSizeShouldBeEqualAfterTransform(sut.correctButton, controlEventOne: .TouchDown, controlEventTwo: .TouchUpInside, resize: nil)
    }

    func testIncorrectButtonTouchDownShouldScaleWhenPressed() {
        testButtonSizeShouldBeEqualAfterTransform(sut.incorrectButton, controlEventOne: .TouchDown, controlEventTwo: nil, resize: 0.85)
    }
    
    func testIncorrectButtonTouchDragExitShouldGetNormalSize() {
        testButtonSizeShouldBeEqualAfterTransform(sut.incorrectButton, controlEventOne: .TouchDown, controlEventTwo: .TouchDragExit, resize: nil)
    }
    
    func testIncorrectTouchCancelShoudGetNormalSize() {
        testButtonSizeShouldBeEqualAfterTransform(sut.incorrectButton, controlEventOne: .TouchDown, controlEventTwo: .TouchUpInside, resize: nil)
    }
    
    //swipedLeft() tested before
    //questionView is outside the screen; answerView -> answerTrailing is active
    func testAnsweredQuestionTransition() {
        sut.swipedLeft()
        sut.answeredQuestionTransition()
        XCTAssertTrue(sut.answerTrailing.active == false)
        XCTAssertTrue(sut.questionView.alpha == 1)
        XCTAssertEqual(sut.questionView.center.x, sut.testView.center.x)
    }
    
    
    //hint: SBNavigationController.swift -> childViewControllerForStatusBarStyle()
    func testEditCurrentFlashcard() {
        var resultClass: String?
        sut.pushDummyData(.Learn)
        
        if let button = sut.navigationItem.rightBarButtonItem {
            sut.editCurrentFlashcard(button)
            if let tmpView = sut.presentedViewController {
                let nextView = tmpView.childViewControllerForStatusBarStyle()
                resultClass = NSStringFromClass((nextView?.classForCoder)!)
            }
        }
        
        XCTAssertEqual(resultClass, "StudyBox_iOS.EditFlashcardViewController")
    }
    

}


extension TestViewControllerTests {
    //mock
    class mockTestViewController: TestViewController {
        var passedFlashcards = 0
        var wasOpened = false
 
        override func answeredQuestionTransition() {
            wasOpened = true
        }
    }
    
    //method test change button sizes
    func testButtonSizeShouldBeEqualAfterTransform(button: UIButton, controlEventOne: UIControlEvents, controlEventTwo: UIControlEvents?, resize: CGFloat?) {
        var buttonWidth = button.frame.size.width
        var buttonHeight = button.frame.size.height
        
        if let resizeButton = resize {
            buttonWidth = buttonWidth * resizeButton
            buttonHeight = buttonHeight * resizeButton
        }
        
        let _ = button.sendActionsForControlEvents(controlEventOne)
        if let secondEvent = controlEventTwo {
            let _ = button.sendActionsForControlEvents(secondEvent)
        }
        
        XCTAssertEqual(buttonWidth, button.frame.size.width, line: #line)
        XCTAssertEqual(buttonHeight, button.frame.size.height, line: #line)
    }
}


extension TestViewController {
    func pushDummyData(testType: StudyType, allHidden: Bool = false) {
        let flashcard = Flashcard(serverID: "a", deckID: "a", question: "a", answer: "a", isHidden: false)
        var flashcardArray = [flashcard]
        for _ in 1...10 {
            if allHidden {
                flashcard.hidden = true
            }
            flashcardArray.append(flashcard)
        }
        testLogicSource = Test(flashcards: flashcardArray, testType: testType, deck: Deck())
    }
}
