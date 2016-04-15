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
    let detailTextFailure = "Może następnym razem się uda."
    var questionText = String()
    var answerText = String()
    var storedFlashcards = [String:String]()
    
    var session : WCSession!
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if context == nil {
            startButton.setHidden(true)
        } else {
            titleLabel.setHidden(true)
            detailLabel.setHidden(true)
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("recievedappcontext")
        print(applicationContext)
        titleLabel.setText("recievedContext")
        startButton.setHidden(false)
        titleLabel.setHidden(true)
        detailLabel.setHidden(true)
        if let flashcards = applicationContext["flashcards"] as? [String:String] {
            print("recievedappcontext2")
            storedFlashcards = flashcards
        }
    }
    
    @IBAction func startButtonPress() {
        randomFlashcardData()
        presentControllerWithNames( ["QuestionViewController", "AnswerViewController"], contexts:
            [["segue": "pagebased", "data": questionText],
            ["segue": "pagebased", "data": answerText]])
    }
    
    func randomFlashcardData() {
            let index = Int(arc4random_uniform(UInt32(storedFlashcards.count)))
            let randomElement = Array(storedFlashcards)[index]
            self.questionText = randomElement.0
            self.answerText = randomElement.1
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
