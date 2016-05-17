//
//  ScoreViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class ScoreViewController: StudyBoxViewController {
    
    @IBOutlet weak var circularProgressView: CircularLoaderView!
    @IBOutlet weak var congratulationsBigLabel: UILabel!
    @IBOutlet weak var congratulationsSmallLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var deckListButton: UIButton!
    @IBOutlet weak var runTestButton: UIButton!
    
    var testLogicSource: Test?
    var testScoreFraction: Double = 0.0
    
    var frameWidth: CGFloat = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        congratulationsBigLabel.font = UIFont.sbFont(size: sbFontSizeSuperLarge, bold: true)
        congratulationsSmallLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        
        deckListButton.backgroundColor = UIColor.sb_Raspberry()
        deckListButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), forState: UIControlState.Normal)
        deckListButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        deckListButton.layer.cornerRadius = 10
        
        completeData()
        if testScoreFraction < 1 {
            runTestButton.backgroundColor = UIColor.sb_Raspberry()
            runTestButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), forState: UIControlState.Normal)
            runTestButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
            runTestButton.layer.cornerRadius = 10
        } else {
            runTestButton.hidden = true 
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
        setupProgressView()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        animateProgressView()
    }
    
    func setupProgressView() {
        frameWidth = circularProgressView.bounds.width
        circularProgressView.circleRadius = frameWidth*2/3
        circularProgressView.progress = 0
    }
    
    func animateProgressView() {
        circularProgressView.animateProgress(CGFloat(testScoreFraction))
    }
    
    ///Sets labels and `testScoreFraction` based on test results
    func completeData() {
        if let testLogic = testLogicSource {
            let cardsResult = testLogic.cardsAnsweredAndPossible()
            
            self.testScoreFraction = Double(cardsResult.0) / Double(cardsResult.1)
            let testScorePercentage = Int(testScoreFraction*100)
            
            scoreLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: true)
            scoreLabel.text = "\(cardsResult.0) / \(cardsResult.1)\n\(testScorePercentage) %"
        }
    }
    
    @IBAction func deckListButtonAction(sender: UIButton) {
        // TODOs: refactor for Drawer menu options
        DrawerViewController.sharedSbDrawerViewControllerChooseMenuOption(atIndex: 1)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "RepeatTest" {
            if let flashcards = testLogicSource?.notPassedInTestDeck where flashcards.isEmpty {
                presentAlertController(withTitle: "Błąd", message: "Brak fiszek do powtórzenia", buttonText: "Ok")
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RepeatTest", let destinationViewController = segue.destinationViewController as? TestViewController,
            let testLogicSource = testLogicSource, flashcards = testLogicSource.notPassedInTestDeck {
            
            destinationViewController.testLogicSource = Test(deck: flashcards, testType: .Test(uint(flashcards.count)), deckName: testLogicSource.deckName)
        }
    }
}
