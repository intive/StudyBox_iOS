//
//  QuestionViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import WatchKit


class QuestionViewController: WKInterfaceController {
    
    @IBOutlet var questionLabel: WKInterfaceLabel!
    var questionText = String()
    var flashcardID = String()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let questionFromContext = context?["question"] as? String, flashcardIDFromContext = context?["flashcardID"] as? String {
            questionText = questionFromContext
            flashcardID = flashcardIDFromContext
        }
        addMenuItemWithItemIcon(.Info, title: "Podpowiedzi", action: #selector(QuestionViewController.showTips))
        questionLabel.setText(questionText)
    }
    
    func showTips() {
        let tipsFromRealm = WatchManager.sharedManager.tipsForFlashcard(flashcardID)
        
        if !tipsFromRealm.isEmpty {
            let controllers = Array(count: tipsFromRealm.count, repeatedValue: "TipViewController")
            presentControllerWithNames(controllers, contexts: tipsFromRealm)
        } else {
            presentAlertControllerWithTitle("Uwaga", message: "Fiszka nie ma podpowiedzi.", preferredStyle: .Alert, actions: [])
        }

        
    }
}
