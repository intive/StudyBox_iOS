//
//  AnswerViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import WatchKit

protocol ModalItemChooserDelegate {
    func didSelectItem(itemSelected:String)
}

class AnswerViewController: WKInterfaceController {
    
    @IBOutlet var answerLabel: WKInterfaceLabel!

    var delegate: InterfaceController?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let answerText = context?["data"] as? String {
            answerLabel.setText(answerText)
        }
        if let dismissContext = context?["dismissContext"] as? InterfaceController {
            self.delegate = dismissContext
        }
    }
    
    @IBAction func correctButtonPress() {
        self.delegate?.didAnswer(true)
        self.dismissController()
    }
    
    @IBAction func incorrectButtonPress() {
        self.delegate?.didAnswer(false)
        self.dismissController()
    }
    
    
}
