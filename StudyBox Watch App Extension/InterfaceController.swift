//
//  InterfaceController.swift
//  StudyBox Watch App Extension
//
//  Created by Kacper Cz on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import RealmSwift

class InterfaceController: WKInterfaceController, WCSessionDelegate, DataSourceChangedDelegate {
    
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var detailLabel: WKInterfaceLabel!
    
    let titleTextNotAvailable = "Nie można rozpocząć testu"
    let titleTextSuccess = "👍"
    let titleTextFailure = "👎"
    
    let detailTextNotAvailable = "Nie zostały wybrane żadne talie do synchronizacji z zegarkiem lub nie zostały one jeszcze zsynchronizowane."
    let detailTextError = "Błąd w otrzymanych danych. Zsynchronizuj talie ponownie."
    let detailTextSuccess = "Masz dobrą pamięć!"
    let detailTextFailure = "Następnym razem się uda."
    
    var questionText = String()
    var answerText = String()
    var tipText = String()
    
    var storedFlashcards = [(String,String,String?)]()
    
    var userAnswer: Bool?
    var session : WCSession!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        WatchManager.sharedManager.startSession()
        
        storedFlashcards = WatchManager.sharedManager.getDataFromRealm()
        updateButtonAndLabels()
    }
    
    override func willActivate() {
        super.willActivate()
        
        if let userAnswer = userAnswer {
            titleLabel.setHidden(false)
            detailLabel.setHidden(false)
            
            titleLabel.setText(userAnswer ? titleTextSuccess : titleTextFailure)
            detailLabel.setText(userAnswer ? detailTextSuccess : detailTextFailure)
        }
    }
    
    func dataSourceDidUpdate() {
//        print("dataSourceDidUpdate")
        storedFlashcards = WatchManager.sharedManager.getDataFromRealm()
        startButton.setHidden(false)
        titleLabel.setText("")
        detailLabel.setText("")
    }
    
    func didAnswer(answer: Bool) {
        self.userAnswer = answer
    }
    
    @IBAction func startButtonPress() {
        randomFlashcardData()
        presentControllerWithNames(["QuestionViewController", "AnswerViewController"], contexts:
            [["segue": "pagebased", "question": questionText, "tip": tipText],
                ["segue": "pagebased", "answer": answerText, "dismissContext": self]])
    }
    
    @IBAction func refreshButtonPress() {
        updateButtonAndLabels()
    }
    
    ///Randomizes a question and answer from `storedFlashcards`
    func randomFlashcardData() {
        let randomElement = storedFlashcards[Int(arc4random_uniform(UInt32(storedFlashcards.count)))]
        self.questionText = randomElement.0
        self.answerText = randomElement.1
        if let randomTip = randomElement.2 {
            self.tipText = randomTip
        }
    }
    
    func updateButtonAndLabels() {
        if storedFlashcards.isEmpty {
            startButton.setHidden(true)
            detailLabel.setText(detailTextNotAvailable)
            titleLabel.setText(titleTextNotAvailable)
        } else {
            startButton.setHidden(false)
            titleLabel.setHidden(true)
            detailLabel.setHidden(true)
        }
    }
}
