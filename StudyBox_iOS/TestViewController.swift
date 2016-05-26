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
    @IBOutlet weak var editFlashcardBarButton: UIBarButtonItem!
    
    @IBOutlet weak var previousTipButton: UIButton!
    @IBOutlet weak var nextTipButton: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var currentQuestionNumber: UILabel!
    
    @IBOutlet weak var answerLeading: NSLayoutConstraint!
    @IBOutlet var answerTrailing: NSLayoutConstraint!
    
    var testLogicSource: Test?
    private lazy var dataManager: DataManager = UIApplication.appDelegate().dataManager
    var tipsForFlashcard = [Tip]()
    var currentTipNumber = 0
    var tipOrQuestionMode = TestModeTipOrQuestion.Question
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Because one Gesture Rec. can be added only to one view, we have to make a second one.
         There are seperate GR's to avoid situation when user presses the button and
         moves out of the button upwards because he changes his mind as to answering correct/incorrect or showing the tip.
        */
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
        
        let swipeUpAnswerLabel = UISwipeGestureRecognizer()
        swipeUpAnswerLabel.direction = .Up
        swipeUpAnswerLabel.addTarget(self, action: #selector(TestViewController.swipedUp))
        answerLabel.userInteractionEnabled = true
        answerLabel.addGestureRecognizer(swipeUpAnswerLabel)
        
        //Set the navigation bar title to current deck name
        if let test = testLogicSource {
            self.title = test.deck.name
            
            //If user is logged in and emails match, we're the author so we can edit flashcards
            if let email = dataManager.remoteDataManager.user?.email {
                editFlashcardBarButton.enabled = test.deck.owner == email
            }
            if test.allFlashcardsHidden {
                //Alert if passed deck have all flashcards hidden
                self.presentAlertController(withTitle: "Uwaga!", message: "Wszystkie fiszki w tali są ukryte", buttonText: "OK")
            }
            if test.passedDeckWasEmpty {
                //Alert if passed deck was empty.
                self.presentAlertController(withTitle: "Uwaga!", message: "Talia jest pusta.", buttonText: "OK")
            }

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
        
		updateQuestionUiForCurrentCard()
        updateAnswerUiForCurrentCard()

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
                                    self.testLogicSource = Test(flashcards: repeatDeck, testType: .Learn, deck: testLogic.deck)
                                    self.answeredQuestionTransition()
                                }
                        })
                    )
                    controller.addAction(
                        UIAlertAction(title: "Nie", style: .Default,
                            handler: { _ in
                                // TODOs: refactor, make enums for DrawerViewControllers menu options
                                DrawerViewController.sharedSbDrawerViewControllerChooseMenuOption(atIndex: 0)
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
            }, completion: { _ in
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
        case .Question: //If current is Question, we're switching to Tip mode
            if let currentCard = testLogicSource?.currentCard {
                dataManager.allTipsForFlashcard(currentCard.deckId, flashcardID: currentCard.serverID, completion: { response in
                    switch response {
                    case .Success(let tipsFromManager):
                        guard !tipsFromManager.isEmpty else {
                            self.presentAlertController(withTitle: "Błąd", message: "Fiszka nie ma podpowiedzi", buttonText: "Ok")
                            return
                        }
                        self.tipsForFlashcard = tipsFromManager.sort {
                            return $0.difficulty < $1.difficulty
                        }
                        self.previousTipButton.tintColor = UIColor.sb_Grey()
                        self.previousTipButton.userInteractionEnabled = false
                        self.nextTipButton.userInteractionEnabled = true
                        self.nextTipButton.tintColor = UIColor.sb_Graphite()
                        self.tipOrQuestionMode = .Tip
                        self.currentTipNumber = 0
                        self.tipButton.setTitle("Pytanie", forState: .Normal)
                        self.updateUIForTipMode(.Tip)
                        
                    case .Error(let err):
                        print(err)
                        self.presentAlertController(withTitle: "Błąd", message: "Nie można pobrać podpowiedzi dla fiszki.", buttonText: "OK")
                    }
                })
            }
        case .Tip: //If current is Tip, we're switching to Question mode
            updateUIForTipMode(.Question)
            currentTipNumber = 0
            tipOrQuestionMode = .Question
        }
    }
    
    @IBAction func nextTipAction(sender: AnyObject) {
        currentTipNumber += 1
        
        if currentTipNumber == tipsForFlashcard.count-1 { //last tip
            UIView.animateWithDuration(0.25) {
                self.previousTipButton.tintColor = UIColor.sb_Graphite()
                self.nextTipButton.tintColor = UIColor.sb_Grey()
            }
            self.nextTipButton.userInteractionEnabled = false
        }
        if currentTipNumber == 1 {
            self.previousTipButton.userInteractionEnabled = true
            UIView.animateWithDuration(0.25) {
                self.previousTipButton.tintColor = UIColor.sb_Graphite()
            }
        }
        self.questionLabel.text = tipsForFlashcard[currentTipNumber].content
    }
    
    @IBAction func previousTipAction(sender: AnyObject) {
        currentTipNumber -= 1
        
        if currentTipNumber == 0 { //first tip
            UIView.animateWithDuration(0.25) {
                self.previousTipButton.tintColor = UIColor.sb_Grey()
                self.nextTipButton.tintColor = UIColor.sb_Graphite()
            }
            self.previousTipButton.userInteractionEnabled = false
        }
        if currentTipNumber == tipsForFlashcard.count-2 {
            UIView.animateWithDuration(0.25) {
                self.nextTipButton.tintColor = UIColor.sb_Graphite()
            }
            self.nextTipButton.userInteractionEnabled = true
        }
        self.questionLabel.text = tipsForFlashcard[currentTipNumber].content
    }

    func updateUIForTipMode(mode: TestModeTipOrQuestion) {
        switch mode {
        case .Question:
            previousTipButton.hidden = true
            nextTipButton.hidden = true
            tipButton.setTitle("Podpowiedź", forState: .Normal)
            questionLabel.text = testLogicSource?.currentCard?.question
        case .Tip:
            if self.tipsForFlashcard.count > 1 {
                self.previousTipButton.hidden = false
                self.nextTipButton.hidden = false
            }
            tipButton.setTitle("Pytanie", forState: .Normal)
            questionLabel.text = tipsForFlashcard[currentTipNumber].content
        }
    }
    
    func updateQuestionUiForCurrentCard() {
        if let testLogic = testLogicSource {
            let points = testLogic.cardsAnsweredAndPossible()
            scoreLabel.text = "\(points.0) / \(points.1)"
        }
        updateUIForTipMode(.Question)
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
    
    @IBAction func correctAnswer(sender: AnyObject) { updateForAnswer(true) }
    @IBAction func incorrectAnswer(sender: AnyObject) { updateForAnswer(false) }
    ///Global time setting for button scale animations
    let buttonsAnimationTime: NSTimeInterval = 0.1
    ///Global scale setting for button scale animations
    let buttonsScaleWhenPressed = CGAffineTransformMakeScale(0.85, 0.85)
    
    @IBAction func correctButtonTouchDown(sender: AnyObject) {
        UIView.animateWithDuration(buttonsAnimationTime, delay: 0, options: .CurveEaseOut, animations: {
            self.correctButton.transform = self.buttonsScaleWhenPressed }, completion:nil )
    }
    @IBAction func correctTouchDragExit(sender: AnyObject) {
        UIView.animateWithDuration(buttonsAnimationTime, delay: 0, options: .CurveEaseOut, animations: {
            self.correctButton.transform = CGAffineTransformIdentity }, completion:nil )
    }
    @IBAction func correctTouchCancel(sender: AnyObject) {
        UIView.animateWithDuration(buttonsAnimationTime, delay: 0, options: .CurveEaseOut, animations: {
            self.correctButton.transform = CGAffineTransformIdentity }, completion:nil )
    }
    @IBAction func incorrectButtonTouchDown(sender: AnyObject) {
        UIView.animateWithDuration(buttonsAnimationTime, delay:0, options: .CurveEaseOut, animations: {
            self.incorrectButton.transform = self.buttonsScaleWhenPressed }, completion:nil )
    }
    @IBAction func incorrectTouchDragExit(sender: AnyObject) {
        UIView.animateWithDuration(buttonsAnimationTime, delay: 0, options: .CurveEaseOut, animations: {
            self.incorrectButton.transform = CGAffineTransformIdentity }, completion:nil )
    }
    @IBAction func incorrectTouchCancel(sender: AnyObject) {
        UIView.animateWithDuration(buttonsAnimationTime, delay: 0, options: .CurveEaseOut, animations: {
            self.incorrectButton.transform = CGAffineTransformIdentity }, completion:nil )
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
            completion: { _ in
                self.answerView.alpha = 1
        })
        //set buttons size back to normal
        incorrectButton.transform = CGAffineTransformIdentity
        correctButton.transform = CGAffineTransformIdentity
        
        updateAnswerUiForCurrentCard()
    }
    
    @IBAction func editCurrentFlashcard(sender: UIBarButtonItem) {
        
        if let testLogicSource = testLogicSource, card = testLogicSource.currentCard,
            editFlashcardNavigation = storyboard?.instantiateViewControllerWithIdentifier(Utils.UIIds.EditFlashcardViewControllerID),
            editFlashcardViewController = editFlashcardNavigation.childViewControllers[0] as? EditFlashcardViewController {
            editFlashcardViewController.mode = EditFlashcardViewControllerMode.Modify(flashcard: card, updateCallback: {[weak self] ( _ ) in
                self?.updateQuestionUiForCurrentCard()
                self?.updateAnswerUiForCurrentCard()
                })
            presentViewController(editFlashcardNavigation, animated: true, completion: nil)
        }
    }
}

extension TestViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
