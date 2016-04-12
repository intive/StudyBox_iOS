//
//  InterfaceController.swift
//  StudyBox Watch App Extension
//
//  Created by Kacper Cz on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var detailLabel: WKInterfaceLabel!
    
    let titleTextNotAvailable = "Nie można rozpocząć testu"
    let titleTextSuccess = "Super!"
    let titleTextFailure = "Niestety..."
    
    let detailTextNotAvailable = "Nie zostały wybrane żadne talie do synchronizacji z zegarkiem lub nie zostały one jeszcze zsynchronizowane."
    let detailTextSuccess = "Masz dobrą pamięć 😃"
    let detailTextFailure = "Może następnym razem się uda."
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        //startButton.setHidden(false)
        // Configure interface objects here.
    }
    
    @IBAction func startButtonPress() {
        presentControllerWithNames( ["QuestionViewController", "AnswerViewController"], contexts:
            [["segue": "pagebased", "data": "questionText"],
            ["segue": "pagebased", "data": "answerText"]])
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
