//
//  ScoreViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class ScoreViewController: StudyBoxViewController {

    @IBOutlet weak var circularProgressView: UIView!
    @IBOutlet weak var congratulationsBigLabel: UILabel!
    @IBOutlet weak var congratulationsSmallLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var deckListButton: UIButton!
    @IBOutlet weak var runTestButton: UIButton!
    
    var testLogicSource:Test?
    var testScoreFraction:Double = 0.0
    var progress = KDCircularProgress()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        congratulationsBigLabel.font = UIFont.sbFont(size: sbFontSizeSuperLarge, bold: true)
        congratulationsSmallLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        
        deckListButton.backgroundColor = UIColor.sb_Raspberry()
        deckListButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), forState: UIControlState.Normal)
        deckListButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        deckListButton.layer.cornerRadius = 10
        
        runTestButton.backgroundColor = UIColor.sb_Raspberry()
        runTestButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), forState: UIControlState.Normal)
        runTestButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        runTestButton.layer.cornerRadius = 10
        
        completeData()
        setupProgressView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        animateProgressView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        progress.pauseAnimation()
    }
    
    func completeData() {
        if let testLogic = testLogicSource {
            let cardsResult = testLogic.cardsAnsweredAndPossible()
            
            self.testScoreFraction = Double(cardsResult.0) / Double(cardsResult.1)
            let testScorePercentage = Int(testScoreFraction*100)
            
            scoreLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: true)
            scoreLabel.text = "\(cardsResult.0) / \(cardsResult.1)\n\(testScorePercentage) %"
            
            switch testLogic.testType {
            case .Learn:
                runTestButton.enabled = false
            default:
                break
            }
        }
    }

    func setupProgressView() {
        
        let progressViewFrame = circularProgressView.bounds
        //let progressViewFrame = CGRect(x:circularProgressView.frame.origin.x,y:circularProgressView.frame.origin.y,width:circularProgressView.frame.width*0.75,height: circularProgressView.frame.height*0.75)
        progress.center = circularProgressView.center
        progress = KDCircularProgress(frame: progressViewFrame, color: UIColor.sb_DarkBlue())
        
        circularProgressView.addSubview(progress)
    }
    
    ///Animating the circular progress view to testPercentage value, after 1 second from calling
    func animateProgressView() {
        //Convert float to degree angle
        let percentageAngle = Int(self.testScoreFraction*360)
        
        //Delay the animation by 1 second
        let triggerTime = (Int64(NSEC_PER_SEC) * 1)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.progress.animateToAngle(percentageAngle, duration: 3, completion: nil)
        })
    }
    
    @IBAction func deckListButtonAction(sender: UIButton) {
        // TODO refactor for Drawer menu options
        DrawerViewController.sharedSbDrawerViewControllerChooseMenuOption(atIndex: 1)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "RepeatTest" {
            if let flashcards = testLogicSource?.notPassedInTestDeck where flashcards.count == 0 {
                presentAlertController(withTitle: "Błąd", message: "Brak fiszek do powtórzenia", buttonText: "Ok")
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RepeatTest", let destinationViewController = segue.destinationViewController as? TestViewController, let flashcards = testLogicSource?.notPassedInTestDeck {
            
            destinationViewController.testLogicSource = Test(deck: flashcards, testType: .Test(uint(flashcards.count)))
        }
    }
}



