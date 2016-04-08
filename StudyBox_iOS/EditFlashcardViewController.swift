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
    
    private var flashcard:Flashcard!
    private var deckName:String?
    
    var mode:EditFlashcardViewControllerMode! {
        didSet {
            if isViewLoaded() {
                updateUiForCurrentMode()
            }
        }
    }
    
    var dataManager:DataManager? {
        return UIApplication.appDelegate().dataManager
    }
    
    func clearInput(){
        deckField.text = nil
        questionField.text = nil
        tipField.text = nil
        answerField.text = nil
        
    }
    
    private func updateUiForCurrentMode() {
        clearInput()
        
        switch mode {
        case .Modify(let deckName,let card)?:
            flashcard = card
            self.deckName = deckName
            
            deckField.text = deckName
            questionField.text = card.question
            tipField.text = card.tip
            answerField.text = card.answer
            navigationItem.title = "Edytuj"
        case .Add?:
            navigationItem.title = "Stwórz"
            flashcard = nil
        default:
            navigationItem.title = nil
            flashcard = nil
            deckName = nil
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(mode != nil, "mode not choosen!")
        
        updateUiForCurrentMode()
    }
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        
        guard let answer = answerField.text, question = questionField.text else {
            presentAlertController(withTitle: "Błąd", message: "Pola odpowiedzi i pytania nie mogą być puste", buttonText: "Ok")
            return
        }
        
        var tip:Tip?
        if let tipText = tipField.text {
            tip = Tip.Text(text: tipText)
        }
        
        if case .Add? = mode {
            
            if let deckFieldName = deckField.text {
                
                if let dataDeck = dataManager?.deck(withName: deckFieldName, caseSensitive: true) {
                    do {
                        try dataManager?.addFlashcard(forDeckWithId: dataDeck.id, question: question, answer: answer, tip: tip)
                    } catch _ as DataManagerError {
                        presentAlertController(withTitle: "Błąd", message: "Nie udało się dodać fiszki", buttonText: "Ok")
                    } catch let err {
                        print("EditFlashcardViewController adding error : \(err)")
                    }
                    
                }

            }
        } else if case .Modify? = mode {
            
            flashcard.question = question
            flashcard.answer = answer
            flashcard.tipEnum = tip
        
            do {
                try dataManager?.updateFlashcard(flashcard)
            } catch _ as DataManagerError {
                presentAlertController(withTitle: "Błąd", message: "Nie udało się zapisać zmian", buttonText: "Ok")
            } catch let err {
                print("EditFlashcardViewController update error : \(err)")
            }
                
            
        }
        
        
    }
}
