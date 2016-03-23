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
    
    
    var testLogicSource:Test?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //answerView is set outside of screen to appear later at swipe
        //and after answering the question
        answerView.center.x = testView.center.x + testView.frame.size.width
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeftForAnswer = UISwipeGestureRecognizer()
        swipeLeftForAnswer.direction = .Left
        swipeLeftForAnswer.delegate = self
        swipeLeftForAnswer.addTarget(self, action: "swipedLeft")
        questionView.userInteractionEnabled = true
        questionView.addGestureRecognizer(swipeLeftForAnswer)
        
        let swipeUpQuestionLabel = UISwipeGestureRecognizer()
        swipeUpQuestionLabel.direction = .Up
        swipeUpQuestionLabel.delegate = self
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
        
        
        //score label displays score; onclick moves to Score View Controller
        let tapScore = UITapGestureRecognizer(target: self, action: Selector("tapScore:"))
        scoreLabel.userInteractionEnabled = true
        scoreLabel.addGestureRecognizer(tapScore)
        try! testLogicSource?.checkIfPassedDeckIsEmpty()
        try! testLogicSource?.checkIfAllFlashcardsHidden()
        if let _ = testLogicSource {
            updateQuestionUiForCurrentCard()
            updateAnswerUiForCurrentCard()
        }else {
            // TODO unhandled case
        }
    }
    
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if let testLogic = testLogicSource {
            if identifier == "ScoreSegue" {
                switch testLogic.testType {
                case .Learn:
                    let controller = UIAlertController(title: "Koniec", message: "To już wszystkie fiszki, czy chcesz rozpocząć naukę od nowa?", preferredStyle: .Alert)
                    controller.addAction(
                        UIAlertAction(title: "Tak", style: .Default,
                            handler: { _ in
                                if let repeatDeck = testLogic.repeatDeck {
                                    self.testLogicSource = Test(deck: repeatDeck, testType: .Learn)
                                    self.answeredQuestionTransition()
                                }
                            }
                        )
                    )
                    controller.addAction(
                        UIAlertAction(title: "Nie", style: .Default,
                            handler: { _ in
                                // TODO refactor, make enums for DrawerViewControllers menu options
                                DrawerViewController.sharedSbDrawerViewControllerChooseMenuOption(atIndex: 1)
                            }
                        )
                    )
                    presentViewController(controller, animated: true, completion: nil)
                    return false
                default:
                    return true
                }
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nextViewController = segue.destinationViewController as? ScoreViewController {
            nextViewController.testLogicSource = testLogicSource
        }
    }
    
    func tapScore(sender: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("ScoreSegue", sender: self)
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
        var message = ""
        if let currentCard = testLogicSource?.currentCard?.tip {
            message = currentCard.description
        }else {
            message = "Brak podpowiedzi"
        }
        let alertController = UIAlertController(title: "Podpowiedź:", message: message, //TODO: set tip text
            preferredStyle: .Alert)
        
        let actionOk = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(actionOk)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func updateQuestionUiForCurrentCard() {
        if let testLogic = testLogicSource {
            let points = testLogic.cardsAnsweredAndPossible()
            scoreLabel.text = "\(points.0) / \(points.1)"
            
            if let card = testLogic.currentCard != nil ? testLogic.currentCard : testLogic.newFlashcard(answeredCorrect: true) {
                questionLabel.text = card.question
            }
        }
    }
    
    func updateAnswerUiForCurrentCard() {
        if let card = testLogicSource?.currentCard {
            answerLabel.text = card.answer
        }
    }
    
    func updateForAnswer(correct:Bool) {
        
        if let testLogic = testLogicSource {
            
            if let card = correct ? testLogic.correctAnswer() : testLogic.incorrectAnswer() {
                answeredQuestionTransition()
            }else {
                if shouldPerformSegueWithIdentifier("ScoreSegue", sender: self) {
                    performSegueWithIdentifier("ScoreSegue", sender: self)
                }
            }
            
        }
        
    }
    
    ///TouchUpInside event
    @IBAction func correctAnswer(sender: AnyObject) {
        updateForAnswer(true)
        
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
        updateForAnswer(false)
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
        updateQuestionUiForCurrentCard()
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
        updateAnswerUiForCurrentCard()
    }
}


extension TestViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
