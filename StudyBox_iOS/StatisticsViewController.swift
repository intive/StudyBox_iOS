//
//  StatisticsViewController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 22.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class StatisticsViewController: StudyBoxViewController {
    @IBOutlet weak var flashcardsScore: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var decksAmount: UILabel!
    @IBOutlet weak var testsAmount: UILabel!
    @IBOutlet weak var circularProgressView: CircularLoaderView!
    private var localDataManager = UIApplication.appDelegate().dataManager.localDataManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circularProgressView.circleRadius = circularProgressView.bounds.width * 2/3
        circularProgressView.progress = 0
        clearButton.backgroundColor = UIColor.sb_Raspberry()
        clearButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), forState: UIControlState.Normal)
        clearButton.titleLabel?.font = UIFont.sbFont(bold: false)
        clearButton.layer.cornerRadius = 10
        
        infoLabel.font = UIFont.sbFont(bold: false)
        decksAmount.font = UIFont.sbFont(bold: false)
        testsAmount.font = UIFont.sbFont(bold: false)
        flashcardsScore.font = UIFont.sbFont(size: sbFontSizeLarge, bold: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadStatistics()
        
    }
    
    
    func reloadStatistics() {
        let tests = localDataManager.getAll(TestInfo)
        guard !tests.isEmpty else {
            flashcardsScore.text = nil
            decksAmount.text = nil
            testsAmount.text = nil
            infoLabel.text = "Nie przeprowadzono \njeszcze żadnego testu."
            circularProgressView.animateProgress(0)
            clearButton.hidden = true
            return
        }
        clearButton.hidden = false
        infoLabel.text = "Poprawne odpowiedzi:"
        let allFlashcards = tests.reduce(0) {
            return $0.0 + $0.1.answeredFlashcardsCount
        }
        let correctlyAnsweredFlashcards = tests.reduce(0) {
            return $0.0 + $0.1.correctlyAnsweredFlashcardsCount
        }
        flashcardsScore.text = "\(correctlyAnsweredFlashcards)/\(allFlashcards)"
        
        let decks = tests.map { $0.deck }.unqiueElements()
        decksAmount.text = "Ilość testowanych talii: \(decks.count)"
        testsAmount.text = "Ilość testów: \(tests.count)"
        circularProgressView.animateProgress(CGFloat(correctlyAnsweredFlashcards) / CGFloat(allFlashcards))
    }
    
    
    @IBAction func clearStatistics(sender: UIButton) {
        localDataManager.deleteAll(TestInfo)
        reloadStatistics()
    }
}
