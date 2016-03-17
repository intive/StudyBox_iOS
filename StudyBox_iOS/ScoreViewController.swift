//
//  ScoreViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class ScoreViewController: StudyBoxViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var deckListButton: UIButton!
    @IBOutlet weak var runTestButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deckListButton.backgroundColor = UIColor(red: 0.88, green: 0.16, blue: 0.32, alpha: 1.0)
        deckListButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), forState: UIControlState.Normal)
        deckListButton.titleLabel?.font = UIFont.sbFont(bold: false)
        
        runTestButton.backgroundColor = UIColor(red: 0.88, green: 0.16, blue: 0.32, alpha: 1.0)
        runTestButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), forState: UIControlState.Normal)
        runTestButton.titleLabel?.font = UIFont.sbFont(bold: false)
        
        completeData()
    }
    
    func completeData() {
        //temporary variables based on TestViewController
        let tmpData = TestViewController()
        scoreLabel.text = "\(tmpData.testScore) / \(tmpData.questionsInDeck)"
    }
}