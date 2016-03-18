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
  
  //temporary variables
  var testScore=0, questionsInDeck=5
  
  override func viewDidLayoutSubviews() {
    //answerView is set outside of screen to appear later at swipe
    //and after answering the question
    answerView.center.x = testView.center.x + testView.frame.size.width
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let swipeLeftForAnswer = UISwipeGestureRecognizer()
    swipeLeftForAnswer.direction = .Left
    swipeLeftForAnswer.addTarget(self, action: "swipedLeft")
    questionView.userInteractionEnabled = true
    questionView.addGestureRecognizer(swipeLeftForAnswer)
    
    let swipeUpQuestionLabel = UISwipeGestureRecognizer()
    swipeUpQuestionLabel.direction = .Up
    swipeUpQuestionLabel.addTarget(self, action: "swipedUp")
    questionLabel.userInteractionEnabled = true
    questionLabel.addGestureRecognizer(swipeUpQuestionLabel)
    
    /*
    Because one Gesture Rec. can be added only to one view, we have to make a second one. There are seperate GR's to avoid situation when user presses the button and moves out of the button upwards because he changes his mind as to answering correct/incorrect or showing the tip. 
    */
    let swipeUpAnswerLabel = UISwipeGestureRecognizer()
    swipeUpAnswerLabel.direction = .Up
    swipeUpAnswerLabel.addTarget(self, action: "swipedUp")
    answerLabel.userInteractionEnabled = true
    answerLabel.addGestureRecognizer(swipeUpAnswerLabel)
    
    tipButton.backgroundColor = UIColor.sb_Grey()
    correctButton.backgroundColor = UIColor.sb_Grey()
    incorrectButton.backgroundColor = UIColor.sb_Grey()
    questionLabel.backgroundColor = UIColor.sb_Grey()
    answerLabel.backgroundColor = UIColor.sb_Grey()
    
    correctButton.imageView?.contentMode = .ScaleAspectFit
    incorrectButton.imageView?.contentMode = .ScaleAspectFit
    
    tipButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
    correctButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
    incorrectButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
    questionLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
    answerLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
    scoreLabel.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    
    //TODO: set values of questionsInDeck from recieved deck, set first question and answer labels
    
  }
  
  func swipedLeft(){
    UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseOut], animations: {
      self.answerView.center.x = self.testView.center.x
      self.questionView.center.x = self.testView.center.x - self.testView.frame.size.width
      }, completion: nil)
  }
  
  func swipedUp(){
    UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseOut], animations: {
      //move views up
      self.questionView.center.y = self.questionView.center.y - self.testView.frame.size.height
      self.answerView.center.y = self.answerView.center.y - self.testView.frame.size.height
      }, completion: { finished in
        //set views to show questionView after animation
        self.questionView.center.x = self.testView.center.x
        self.answerView.center.x = self.testView.center.x + self.testView.frame.size.width
        
        //set buttons size back to normal in case they were being pressed while swiping
        self.correctButton.transform = CGAffineTransformIdentity
        self.incorrectButton.transform = CGAffineTransformIdentity
        
        //move views back to their correct Y position
        self.questionView.center.y = self.questionView.center.y + self.testView.frame.size.height
        self.answerView.center.y = self.answerView.center.y + self.testView.frame.size.height
        
        //set alpha to 0 to prepare for next animation
        self.questionView.alpha = 0
        self.answerView.alpha = 0
        
        //animate alpha back to 1
        UIView.animateWithDuration(0.5, delay: 0,options: [.CurveEaseOut], animations: {
          self.questionView.alpha = 1
          self.answerView.alpha = 1
          }, completion: nil)
    })
  }
  
  @IBAction func showTip(sender: AnyObject) {
    let alertController = UIAlertController(title: "Podpowiedź:", message: "Message", //TODO: set tip text
      preferredStyle: .Alert)
    
    let actionOk = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alertController.addAction(actionOk)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  ///TouchUpInside event
  @IBAction func correctAnswer(sender: AnyObject) {
    testScore++
    if testScore > questionsInDeck {
      //TODO: preform segue to ScoreViewController
    } else {
      scoreLabel.text = "\(testScore) / \(questionsInDeck)"
      answeredQuestionTransition()
    }
  }
  
  ///Global time setting for button scale animations
  let buttonsAnimationTime: NSTimeInterval = 0.1
  ///Global scale setting for button scale animations
  let buttonsScaleWhenPressed: (CGFloat,CGFloat) = (0.85,0.85)
  
  @IBAction func correctButtonTouchDown(sender: AnyObject) {
    UIView.animateWithDuration(buttonsAnimationTime,delay: 0, options: .CurveEaseOut, animations: {
      self.correctButton.transform = CGAffineTransformMakeScale(self.buttonsScaleWhenPressed)
      }, completion:nil )
  }
  
  @IBAction func correctTouchDragExit(sender: AnyObject) {
    UIView.animateWithDuration(buttonsAnimationTime, delay: 0, options: .CurveEaseOut, animations: {
      self.correctButton.transform = CGAffineTransformIdentity
      }, completion:nil)
  }
  
  @IBAction func correctTouchCancel(sender: AnyObject) {
    UIView.animateWithDuration(buttonsAnimationTime, delay: 0, options: .CurveEaseOut, animations: {
      self.correctButton.transform = CGAffineTransformIdentity
      }, completion:nil)
  }
  
  ///TouchUpInside event
  @IBAction func incorrectAnswer(sender: AnyObject) {
    //TODO: check if there are any questions left?
    answeredQuestionTransition()
  }
  
  @IBAction func incorrectButtonTouchDown(sender: AnyObject) {
    UIView.animateWithDuration(buttonsAnimationTime,delay:0, options: .CurveEaseOut, animations: {
      self.incorrectButton.transform = CGAffineTransformMakeScale(self.buttonsScaleWhenPressed)
      }, completion:nil )
  }
  
  @IBAction func incorrectTouchDragExit(sender: AnyObject) {
    UIView.animateWithDuration(buttonsAnimationTime, delay: 0, options: .CurveEaseOut, animations: {
      self.incorrectButton.transform = CGAffineTransformIdentity
      }, completion:nil)
  }
  
  @IBAction func incorrectTouchCancel(sender: AnyObject) {
    UIView.animateWithDuration(buttonsAnimationTime, delay: 0, options: .CurveEaseOut, animations: {
      self.incorrectButton.transform = CGAffineTransformIdentity
      }, completion:nil)
  }
  
  ///Animation sequence to go back to starting point and display `questionView`
  func answeredQuestionTransition(){
    questionView.alpha = 0
    questionView.center.x = testView.center.x
    
    //TODO: set new question in label before dissolve
    
    //move answerView outside of the screen
    answerView.center.x = testView.center.x + testView.frame.size.width
    
    //animate dissolving of views
    UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut], animations: {
      self.answerView.alpha = 0
      self.questionView.alpha = 1
      }, completion: { Void in
        self.answerView.alpha = 1
    })
    
    //set buttons size back to normal
    incorrectButton.transform = CGAffineTransformIdentity
    correctButton.transform = CGAffineTransformIdentity
    
    //TODO: set new answer in label after animation
  }
}

