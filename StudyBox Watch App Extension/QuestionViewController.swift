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
    @IBOutlet var tipLabel: WKInterfaceLabel!
    @IBOutlet var separatorOutlet: WKInterfaceSeparator!
 
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let questionText = context?["data"] as? String  {
            questionLabel.setText(questionText)
        }
        separatorOutlet.setColor(UIColor(red: (234 / 255.0), green: 0, blue: (97 / 255.0), alpha: 1))
        //let questionText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
        
        
//        if questionText.characters.count < 153 {
//            let screenHeight = WKInterfaceDevice.currentDevice().screenBounds.height
//            questionLabel.setHeight(screenHeight)
//        } else {
//            questionLabel.sizeToFitHeight()
//        }
        tipLabel.setText("podpowiedź!")
        tipLabel.setHidden(false)
        
        
        // Configure interface objects here.
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
