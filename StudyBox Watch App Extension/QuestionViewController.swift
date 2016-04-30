//
//  QuestionViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import WatchKit

enum QuestionVCMode {
    case Question, Tip
}

class QuestionViewController: WKInterfaceController {
    
    @IBOutlet var questionLabel: WKInterfaceLabel!
    var mode = QuestionVCMode.Question
    var questionText = String()
    var tipText = String()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let questionFromContext = context?["question"] as? String, let tipFromContext = context?["tip"] as? String {
            questionText = questionFromContext
            tipText = tipFromContext
        }
        addMenuItemWithItemIcon(.Info, title: "Podpowiedź", action: #selector(QuestionViewController.updateLabel))
        questionLabel.setText(questionText)
    }
    
    func updateLabel() {
        switch mode {
        case .Question:
            //Current mode is Question, so we'll show the tip
            if tipText.isEmpty {
                questionLabel.setText("Do tej fiszki nie ma podpowiedzi.")
            } else {
                questionLabel.setText("Podpowiedź:\n\(tipText)")
            }
        case .Tip:
            questionLabel.setText(questionText)
        }
        updateMenuAndMode()
    }
    
    func updateMenuAndMode() {
        switch mode {
        case .Question:
            mode = .Tip
            clearAllMenuItems()
            addMenuItemWithItemIcon(.Maybe, title: "Pytanie", action: #selector(QuestionViewController.updateLabel))
        case .Tip:
            mode = .Question
            clearAllMenuItems()
            addMenuItemWithItemIcon(.Info, title: "Podpowiedź", action: #selector(QuestionViewController.updateLabel))
        }
    }
}
