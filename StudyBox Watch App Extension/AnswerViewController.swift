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

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let answerText = context?["data"] as? String {
            answerLabel.setText(answerText)
        }
    }
    
}
