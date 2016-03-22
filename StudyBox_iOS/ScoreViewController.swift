//
//  ScoreViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class ScoreViewController: StudyBoxViewController {
    
    
    @IBOutlet weak var congratulationsBigLabel: UILabel!
    @IBOutlet weak var congratulationsSmallLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var deckListButton: UIButton!
    @IBOutlet weak var runTestButton: UIButton!
    
    var questionsInDeck = 0
    var testScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        congratulationsBigLabel.font = UIFont.sbFont(size: sbFontSizeSuperLarge, bold: false)
        congratulationsSmallLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        
        deckListButton.backgroundColor = UIColor.sb_Raspberry()
        deckListButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), forState: UIControlState.Normal)
        deckListButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        
        runTestButton.backgroundColor = UIColor.sb_Raspberry()
        runTestButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), forState: UIControlState.Normal)
        runTestButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        
        completeData()
    }
    
    func completeData() {
        //temporary variables based on TestViewController
        scoreLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        scoreLabel.text = "\(testScore) / \(questionsInDeck)"
    }
}