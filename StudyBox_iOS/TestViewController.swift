import UIKit

enum TestModeTipOrQuestion {
    case Tip
    case Question
}

class TestViewController: StudyBoxViewController {
    
    @IBOutlet var testView: UIView!
    
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tipButton: UIButton!
    
    @IBOutlet weak var answerView: UIView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var correctButton: UIButton!
    @IBOutlet weak var incorrectButton: UIButton!
    
    @IBOutlet weak var previousTipButton: UIButton!
    @IBOutlet weak var previousTipWidth: NSLayoutConstraint!
    
    @IBOutlet weak var nextTipButton: UIButton!
    @IBOutlet weak var nextTipWidth: NSLayoutConstraint!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var currentQuestionNumber: UILabel!
    
    @IBOutlet weak var answerLeading: NSLayoutConstraint!
    @IBOutlet var answerTrailing: NSLayoutConstraint!
    
    var testLogicSource: Test?
    var tipsForFlashcard = [Tip]()
    var currentTipNumber = 0
    var tipOrQuestionMode = TestModeTipOrQuestion.Question
    
    private var dataManager: DataManager? = {
        return UIApplication.appDelegate().dataManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeftForAnswer = UISwipeGestureRecognizer()
        swipeLeftForAnswer.direction = .Left
        swipeLeftForAnswer.delegate = self
        swipeLeftForAnswer.addTarget(self, action: #selector(TestViewController.swipedLeft))
        questionView.userInteractionEnabled = true
        questionView.addGestureRecognizer(swipeLeftForAnswer)
        
        let swipeUpQuestionLabel = UISwipeGestureRecognizer()
        swipeUpQuestionLabel.direction = .Up
        swipeUpQuestionLabel.delegate = self
        swipeUpQuestionLabel.addTarget(self, action: #selector(TestViewController.swipedUp))
        questionLabel.userInteractionEnabled = true
        questionLabel.addGestureRecognizer(swipeUpQuestionLabel)
        
        /*
         Because one Gesture Rec. can be added only to one view, we have to make a second one. 
         There are seperate GR's to avoid situation when user presses the button and 
         moves out of the button upwards because he changes his mind as to answering correct/incorrect or showing the tip.
         */
        let swipeUpAnswerLabel = UISwipeGestureRecognizer()
        swipeUpAnswerLabel.direction = .Up
        swipeUpAnswerLabel.addTarget(self, action: #selector(TestViewController.swipedUp))
        answerLabel.userInteractionEnabled = true
        answerLabel.addGestureRecognizer(swipeUpAnswerLabel)
        
        //Set the navigation bar title to current deck name
        if let test = testLogicSource {
            self.title = test.deckName
        }

        tipButton.backgroundColor = UIColor.sb_Grey()
        correctButton.backgroundColor = UIColor.sb_Grey()
        incorrectButton.backgroundColor = UIColor.sb_Grey()
        questionLabel.backgroundColor = UIColor.sb_Grey()
        answerLabel.backgroundColor = UIColor.sb_Grey()
        
        correctButton.imageView?.contentMode = .ScaleAspectFit
        incorrectButton.imageView?.contentMode = .ScaleAspectFit
        previousTipButton.imageView?.contentMode = .ScaleAspectFit
        nextTipButton.imageView?.contentMode = .ScaleAspectFit
        
        previousTipButton.hidden = true
        nextTipButton.hidden = true
        tipOrQuestionMode = .Question
        
        tipButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        correctButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        incorrectButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        questionLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        answerLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        scoreLabel.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        currentQuestionNumber.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        
        currentQuestionNumber.text = "#1"
        
        //Alert if passed deck was empty.
        if (testLogicSource?.checkIfPassedDeckIsEmpty()) == true {
            let msg = "Talia jest pusta."
            let alert = UIAlertController(title: "Uwaga!", message: msg, preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        //Alert if passed deck have all flashcards hidden
        if (testLogicSource?.checkIfAllFlashcardsHidden()) == true {
            let msg = "Wszystkie fiszki w tali są ukryte"
            let alert = UIAlertController(title: "Uwaga!", message: msg, preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        if let _ = testLogicSource {
            updateQuestionUiForCurrentCard()
            updateAnswerUiForCurrentCard()
        } else {
            // TODOs: unhandled case
        }
        answerTrailing.active = false
        answerLeading.constant = view.frame.width
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if let testLogic = testLogicSource {
            if identifier == "ScoreSegue" {
                switch testLogic.testType {
                case .Learn:
                    let controller = UIAlertController(title: "Koniec", message: "To już wszystkie fiszki, czy chcesz rozpocząć naukę od nowa?",
                                                       preferredStyle: .Alert)
                    controller.addAction(
                        UIAlertAction(title: "Tak", style: .Default,
                            handler: { _ in
                                if let repeatDeck = testLogic.repeatDeck {
                                    self.testLogicSource = Test(deck: repeatDeck, testType: .Learn, deckName: testLogic.deckName)
                                    self.answeredQuestionTransition()
                                }
                            })
                    )
                    controller.addAction(
                        UIAlertAction(title: "Nie", style: .Default,
                            handler: { _ in
                                // TODOs: refactor, make enums for DrawerViewControllers menu options
                                DrawerViewController.sharedSbDrawerViewControllerChooseMenuOption(atIndex: 1)
                            })
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
    
    func swipedLeft(){
        view.layoutIfNeeded()
        self.answerLeading.constant = 0
        self.tipOrQuestionMode = .Question
        self.nextTipButton.hidden = true
        self.previousTipButton.hidden = true
        
        UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseOut], animations: {
            self.answerTrailing.active = true 
            self.view.layoutIfNeeded()
            self.questionView.center.x = self.testView.center.x - self.testView.frame.size.width
            }, completion: nil)
    }
    
    func swipedUp(){
        UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseOut], animations: {
            //move views up
            self.questionView.center.y = self.questionView.center.y - self.testView.frame.size.height
            self.answerView.center.y = self.answerView.center.y - self.testView.frame.size.height
            
            //set alpha to 0 to prepare for next animation +fade-out effect
            self.questionView.alpha = 0
            self.answerView.alpha = 0
            }, completion: { finished in
                if let testLogic = self.testLogicSource {
                    testLogic.skipCard()
                }
                self.updateQuestionUiForCurrentCard()
                self.updateAnswerUiForCurrentCard()

                //set views to show questionView after animation
                self.questionView.center.x = self.testView.center.x
                self.answerTrailing.active = false
                self.answerLeading.constant = self.view.frame.width
                //move views back to their correct Y position
                self.questionView.center.y = self.questionView.center.y + self.testView.frame.size.height
                self.answerView.center.y = self.answerView.center.y + self.testView.frame.size.height
                
                //animate alpha back to 1
                UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseOut], animations: {
                    self.questionView.alpha = 1
                    self.answerView.alpha = 1
                    }, completion: nil)
        })
    }
    
    @IBAction func showTip(sender: AnyObject) {
        switch tipOrQuestionMode {
        case .Question:
            if let currentCard = testLogicSource?.currentCard {
                dataManager.allTipsForFlashcard(currentCard.deckId, flashcardID: currentCard.serverID, completion: { response in
                    switch response {
                    case .Success(let tipsFromManager):
                        guard !tipsFromManager.isEmpty else {
                            self.presentAlertController(withTitle: "Błąd", message: "Fiszka nie ma podpowiedzi", buttonText: "Ok")
                            return
                        }
                        
                        let sortedTips = tipsFromManager.sort {
                            return $0.difficulty < $1.difficulty
                        }
                        self.tipsForFlashcard = sortedTips
                        self.questionLabel.text = sortedTips[0].content
                        self.previousTipButton.tintColor = UIColor.sb_Grey()
                        self.nextTipButton.tintColor = UIColor.sb_Graphite()
                        
                        if self.tipsForFlashcard.count > 1 {
                            self.previousTipButton.hidden = false
                            self.nextTipButton.hidden = false
                        }
                        
                        self.tipOrQuestionMode = .Tip
                        self.currentTipNumber = 0
                        self.tipButton.setTitle("Pytanie", forState: .Normal)
                        
                    case .Error(let err):
                        print(err)
                        self.presentAlertController(withTitle: "Błąd", message: "Nie można pobrać podpowiedzi dla fiszki.", buttonText: "OK")
                    }
                })

            }
            
        case .Tip:
            previousTipButton.hidden = true
            nextTipButton.hidden = true
            tipButton.setTitle("Podpowiedź", forState: .Normal)
            tipOrQuestionMode = .Question
            questionLabel.text = testLogicSource?.currentCard?.question
        }
    }

    @IBAction func tipButtonTap(sender: AnyObject) {
        switch sender.tag {
        case 0: //previous tip
            currentTipNumber -= 1
            
            if currentTipNumber == 0 { //first tip
                self.previousTipButton.tintColor = UIColor.sb_Grey()
                self.nextTipButton.tintColor = UIColor.sb_Graphite()
                self.previousTipButton.userInteractionEnabled = false
            }
            if currentTipNumber == tipsForFlashcard.count-2 {
                self.nextTipButton.tintColor = UIColor.sb_Graphite()
                self.nextTipButton.userInteractionEnabled = true
            }
        case 1: //next tip
            currentTipNumber += 1

            if currentTipNumber == tipsForFlashcard.count-1 { //last tip
                self.previousTipButton.tintColor = UIColor.sb_Graphite()
                self.nextTipButton.tintColor = UIColor.sb_Grey()
                self.nextTipButton.userInteractionEnabled = false
            }
            if currentTipNumber == 1 {
                self.previousTipButton.userInteractionEnabled = true
                self.previousTipButton.tintColor = UIColor.sb_Graphite()
            }
        default:
            return

        }
        self.questionLabel.text = tipsForFlashcard[currentTipNumber].content
    }
    
    func updateQuestionUiForCurrentCard() {
        if let testLogic = testLogicSource {
            let points = testLogic.cardsAnsweredAndPossible()
            scoreLabel.text = "\(points.0) / \(points.1)"
            
            if let card = testLogic.currentCard {
                questionLabel.text = card.question
            }
        }
    }
    
    func updateAnswerUiForCurrentCard() {
        if let test = testLogicSource, card = test.currentCard {
            answerLabel.text = card.answer
            currentQuestionNumber.text = "#\(test.index)"
        }
    }
    
    func updateForAnswer(correct: Bool) {
        
        if let testLogic = testLogicSource {
            
            if (correct ? testLogic.correctAnswer() : testLogic.incorrectAnswer()) != nil {
                answeredQuestionTransition()
            } else {
                if shouldPerformSegueWithIdentifier("ScoreSegue", sender: self) {
                    performSegueWithIdentifier("ScoreSegue", sender: self)
                }
            }
        }
    }
    
    //ouchUpInside event
    @IBAction func correctAnswer(sender: AnyObject) {
        updateForAnswer(true)
    }
    
    ///Global time setting for button scale animations
    let buttonsAnimationTime: NSTimeInterval = 0.1
    ///Global scale setting for button scale animations
    let buttonsScaleWhenPressed = CGAffineTransformMakeScale(0.85, 0.85)
    
    @IBAction func correctButtonTouchDown(sender: AnyObject) {
        UIView.animateWithDuration(buttonsAnimationTime, delay: 0, options: .CurveEaseOut, animations: {
            self.correctButton.transform = self.buttonsScaleWhenPressed
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
    
    //TouchUpInside event
    @IBAction func incorrectAnswer(sender: AnyObject) {
        updateForAnswer(false)
    }
    
    @IBAction func incorrectButtonTouchDown(sender: AnyObject) {
        UIView.animateWithDuration(buttonsAnimationTime, delay:0, options: .CurveEaseOut, animations: {
            self.incorrectButton.transform = self.buttonsScaleWhenPressed
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
        
        updateQuestionUiForCurrentCard()
        //move answerView outside of the screen
        answerTrailing.active = false
        answerLeading.constant = view.frame.width
        
        //animate dissolving of views
        UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseInOut],
            animations: {
                self.answerView.alpha = 0
                self.questionView.alpha = 1
            },
            completion: { Void in
                self.answerView.alpha = 1
        })
        
        //set buttons size back to normal
        incorrectButton.transform = CGAffineTransformIdentity
        correctButton.transform = CGAffineTransformIdentity
        
        updateAnswerUiForCurrentCard()
    }
    @IBAction func editCurrentFlashcard(sender: UIBarButtonItem) {
        if let card = testLogicSource?.currentCard,
            editFlashcardNavigation = storyboard?.instantiateViewControllerWithIdentifier(Utils.UIIds.EditFlashcardViewControllerId) {
            if let editFlashcardViewController = editFlashcardNavigation.childViewControllers[0] as? EditFlashcardViewController {
                editFlashcardViewController.mode = EditFlashcardViewControllerMode.Modify(flashcard: card, updateCallback: {[weak self] ( _ ) in
                    self?.updateQuestionUiForCurrentCard()
                    self?.updateAnswerUiForCurrentCard()
                    
                })
                presentViewController(editFlashcardNavigation, animated: true, completion: nil)
                
            }
          
        }
        
    }
}

extension TestViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
