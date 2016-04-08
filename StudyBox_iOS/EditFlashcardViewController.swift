//
//  EditFicheViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

enum EditFlashcardViewControllerMode {
    case Add,Modify(deckName:String,flashcard:Flashcard)
}

class EditFlashcardViewController: StudyBoxViewController {
    
    @IBOutlet weak var deckField: UITextField!
    @IBOutlet weak var questionField: UITextField!
    @IBOutlet weak var tipField: UITextField!
    @IBOutlet weak var answerField: UITextField!
    private var flashcard:Flashcard?
    private var deckName:String?
    
    var mode:EditFlashcardViewControllerMode? {
        didSet {
            if let editMode = mode {
                switch editMode {
                case .Modify(let deckName,let card):
                    flashcard = card
                    self.deckName = deckName
                    
                    deckField.text = deckName
                    questionField.text = card.question
                    tipField.text = card.tip
                    answerField.text = card.answer
                    navigationItem.title = "Edytuj"
                case .Add:
                    navigationItem.title = "Stwórz"
                }
            }else {
                clearInput()
                navigationItem.title = nil
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        assert(mode != nil, "Mode not choosen!")
    }
    
    func clearInput(){
        deckField.text = nil
        questionField.text = nil
        tipField.text = nil
        answerField.text = nil

    }

    @IBAction func saveAction(sender: UIBarButtonItem) {
        /// TODO send data to server
    }
}
