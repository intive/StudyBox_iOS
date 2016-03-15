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
  var testScore=0, questionsInDeck=20
  
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
    
    tipButton.backgroundColor = UIColor.sb_Grey()
    correctButton.backgroundColor = UIColor.sb_Grey()
    incorrectButton.backgroundColor = UIColor.sb_Grey()
    questionLabel.backgroundColor = UIColor.sb_Grey()
    answerLabel.backgroundColor = UIColor.sb_Grey()
    
    correctButton.imageView!.contentMode = .ScaleAspectFit
    incorrectButton.imageView!.contentMode = .ScaleAspectFit

    
    tipButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
    correctButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
    incorrectButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
    questionLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
    answerLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
    scoreLabel.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    
    //TODO: set values of questionsInDeck from recieved deck, set first question and answer labels
    testScore = 0
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
  
  @IBAction func correctAnswer(sender: AnyObject) {
    //type is Touch Up Inside
    
    //TODO: check if there are any questions left
    answeredQuestionTransition()
    
    testScore++
    scoreLabel.text = "\(testScore) / \(questionsInDeck)"
      
  }
  
  let animationTime:NSTimeInterval = 0.1
  
  @IBAction func correctButtonTouchDown(sender: AnyObject) {
    
    UIView.animateWithDuration(animationTime,delay:0, options: .CurveEaseOut, animations: {
        self.correctButton.transform = CGAffineTransformMakeScale(0.85, 0.85)
      }, completion:nil )
  }
  
  @IBAction func correctTouchDragExit(sender: AnyObject) {

    UIView.animateWithDuration(animationTime, delay: 0, options: .CurveEaseOut, animations: {
      self.correctButton.transform = CGAffineTransformIdentity
      }, completion:nil)
  }
  
  @IBAction func incorrectAnswer(sender: AnyObject) {
    //type is Touch Up Inside

    //TODO: check if there are any questions left
    answeredQuestionTransition()
    
  }
  
  @IBAction func incorrectButtonTouchDown(sender: AnyObject) {
    UIView.animateWithDuration(animationTime,delay:0, options: .CurveEaseOut, animations: {
      self.incorrectButton.transform = CGAffineTransformMakeScale(0.85, 0.85)
      }, completion:nil )
  }
  
  @IBAction func incorrectTouchDragExit(sender: AnyObject) {
    UIView.animateWithDuration(animationTime, delay: 0, options: .CurveEaseOut, animations: {
      self.incorrectButton.transform = CGAffineTransformIdentity
      }, completion:nil)
  }
  
  func answeredQuestionTransition(){
    
    //TODO: if there aren't any flashcards left, then segue to result view
    //else: below
    
    questionView.alpha = 0
    questionView.center.x = testView.center.x
    
    //TODO: set new question in label before dissolve
    
    answerView.center.x = testView.center.x + testView.frame.size.width
    
    UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut], animations: {
      self.answerView.alpha = 0
      self.questionView.alpha = 1
      }, completion: {
        (value: Bool) in
        self.answerView.alpha = 1
    })
    incorrectButton.transform = CGAffineTransformIdentity
    correctButton.transform = CGAffineTransformIdentity
    //TODO: set new answer in label after animation
  }
}

