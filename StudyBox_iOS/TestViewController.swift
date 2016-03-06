//
//  TestViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class TestViewController: StudyBoxViewController {

  @IBOutlet var testView: UIView!
  
  @IBOutlet weak var questionView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var tipButton: UIButton!
  
  @IBOutlet weak var answerView: UIView!
  @IBOutlet weak var answerLabel: UILabel!
  @IBOutlet weak var correctButton: UIButton!
  @IBOutlet weak var incorrectButton: UIButton!
  
  @IBOutlet weak var scoreLabel: UILabel!
  
  internal var currentDeckForTesting:Deck?
  var testScore=0, currentQuestionNumber=0, questionsInDeck=0
  
  override func viewDidLayoutSubviews() {
    tipButton.backgroundColor = UIColor.lightGrayColor()
    correctButton.backgroundColor = UIColor.lightGrayColor()
    incorrectButton.backgroundColor = UIColor.lightGrayColor()
    
    //answerView is set outside of screen to appaer later at swipe
    answerView.center.x = testView.center.x + testView.frame.size.width
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let swipeLeftForAnswer = UISwipeGestureRecognizer()
    swipeLeftForAnswer.direction = .Left
    swipeLeftForAnswer.addTarget(self, action: "swipedLeft")
    questionView.userInteractionEnabled = true
    questionView.addGestureRecognizer(swipeLeftForAnswer)
  
    //TODO: set values of questionsInDeck from recieved deck, set first question and answer for the view
    
    testScore = 0
    currentQuestionNumber = 0
    questionsInDeck = 20
  }
  
  
  func swipedLeft(){
    
    UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseOut], animations: {
      self.answerView.center.x = self.testView.center.x
      self.questionView.center.x = self.testView.center.x - self.testView.frame.size.width
      }, completion: nil)
    
  }
  
  @IBAction func showTip(sender: AnyObject) {
    
    let alertController = UIAlertController(title: "Podpowiedź:",
      message: "Message", //TODO: set tip text
      preferredStyle: .Alert)
    let actionOk = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alertController.addAction(actionOk)
    
    self.presentViewController(alertController, animated: true, completion: nil)
    
  }
  
  @IBAction func correctAnswerAction(sender: AnyObject) {
    
    //TODO: check if there are any questions left
    /*
    */
    answeredQuestionTransition()
    testScore++
    scoreLabel.text = "\(testScore) / \(questionsInDeck)"
    
  }
  
  @IBAction func incorrectAnswerAction(sender: AnyObject) {
     //TODO: check if there are any questions left
    answeredQuestionTransition()

  }
  
  func answeredQuestionTransition(){
    
    questionView.alpha = 0
    questionView.center.x = testView.center.x
    //TODO: set new question in label
    
    answerView.center.x = testView.center.x + testView.frame.size.width
    
    UIView.animateWithDuration(1, delay: 0, options: [.CurveEaseInOut], animations: {
      self.answerView.alpha = 0
      self.questionView.alpha = 1
      }, completion: {
        (value: Bool) in
        self.answerView.alpha = 1
        
    })
    
    //TODO: set new answer in label
    
  }
  
  func setNewFlashcard(newFlashcard:Int) -> (Bool) {
    //returns true if Flashcard that is about to be set is the last one
    
    if (newFlashcard == questionsInDeck){
    return true
    } else {
      
      
      
      return false
    }
  
  }
  
  
}
