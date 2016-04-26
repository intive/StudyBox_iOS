//
//  AnswerViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import WatchKit

class AnswerViewController: WKInterfaceController {
    
    @IBOutlet var answerLabel: WKInterfaceLabel!
    var delegate: InterfaceController?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let answerText = context?["answer"] as? String {
            answerLabel.setText(answerText)
        }
        if let dismissContext = context?["dismissContext"] as? InterfaceController {
            self.delegate = dismissContext
        }
    }
    
    @IBAction func correctButtonPress() {
        self.delegate?.didAnswerCorrect(true)
        self.dismissController()
    }
    
    @IBAction func incorrectButtonPress() {
        self.delegate?.didAnswerCorrect(false)
        self.dismissController()
    }
    
    
}
