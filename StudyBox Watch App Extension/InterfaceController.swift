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

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var detailLabel: WKInterfaceLabel!
    
    let titleTextNotAvailable = "Nie można rozpocząć testu"
    let titleTextSuccess = "😄"
    let titleTextFailure = "😟"
    
    let detailTextNotAvailable = "Nie zostały wybrane żadne talie do synchronizacji z zegarkiem lub nie zostały one jeszcze zsynchronizowane."
    let detailTextSuccess = "Masz dobrą pamięć!"
    let detailTextFailure = "Następnym razem się uda."
    
    var questionText = String()
    var answerText = String()
    
    var storedFlashcards = [(String,String)]()
    var userAnswer: Bool?
    var session : WCSession!
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        userAnswer = nil
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if context == nil {
            startButton.setHidden(true)
            detailLabel.setText(detailTextNotAvailable)
            titleLabel.setText(titleTextNotAvailable)
        } else {
            titleLabel.setHidden(true)
            detailLabel.setHidden(true)
        }
    }
    
    func didAnswer(answer: Bool) {
        self.userAnswer = answer
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        startButton.setHidden(false)
        titleLabel.setText("")
        detailLabel.setText("")
        //Update `storedFlashcards` to data recieved from iPhone
        if let flashcardsQ = applicationContext["flashcardsQuestions"] as? [String], let flashcardsA = applicationContext["flashcardsAnswers"] as? [String] where flashcardsQ.count == flashcardsA.count {
            for i in 0..<flashcardsQ.count {
                storedFlashcards.append((flashcardsQ[i],flashcardsA[i]))
            }
        }
    }
    
    @IBAction func startButtonPress() {
        randomFlashcardData()
        presentControllerWithNames(["QuestionViewController", "AnswerViewController"], contexts:
            [["segue": "pagebased", "data": questionText],
            ["segue": "pagebased", "data": answerText, "dismissContext": self]])
    }
    
    ///Returns a random question and answer from `storedFlashcards`
    func randomFlashcardData() {
            let index = Int(arc4random_uniform(UInt32(storedFlashcards.count)))
            let randomElement = storedFlashcards[index]
            self.questionText = randomElement.0
            self.answerText = randomElement.1
    }

    override func willActivate() {
        super.willActivate()
        
        if let userAnswer = userAnswer {
            if userAnswer {
                titleLabel.setHidden(false)
                detailLabel.setHidden(false)
                titleLabel.setText(titleTextSuccess)
                detailLabel.setText(detailTextSuccess)
                detailLabel.setTextColor(UIColor.greenColor())
            } else {
                titleLabel.setHidden(false)
                detailLabel.setHidden(false)
                titleLabel.setText(titleTextFailure)
                detailLabel.setText(detailTextFailure)
                detailLabel.setTextColor(UIColor.redColor())
            }
        }
    }
}
