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
    var tipsFromRealm = [String]()
    @IBOutlet var tipButton: WKInterfaceButton!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let questionFromContext = context?["question"] as? String, flashcardIDFromContext = context?["flashcardID"] as? String {
            questionText = questionFromContext
            flashcardID = flashcardIDFromContext
        }
        tipsFromRealm = WatchManager.sharedManager.tipsForFlashcard(flashcardID)
        
        if tipsFromRealm.isEmpty {
            tipButton.setHidden(true)
        }
        
        questionLabel.setText(questionText)
    }
    
    @IBAction func showTip() {
        let controllers = Array(count: tipsFromRealm.count, repeatedValue: "TipViewController")
        presentControllerWithNames(controllers, contexts: tipsFromRealm)
    }
}
