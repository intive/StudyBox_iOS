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
    override func viewDidLoad() {
        
        completeData()
    }
    
    func completeData() {
        //temporary variables based on TestViewController
        let tmpData = TestViewController()
        scoreLabel.text = "\(tmpData.testScore) / \(tmpData.questionsInDeck)"
    }
}