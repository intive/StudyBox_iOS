//
//  EditFicheViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

enum EditFlashcardViewControllerMode {
    case Add,Modify(flashcard:Flashcard)
}

class EditFlashcardViewController: StudyBoxViewController {
    
    
    lazy var searchController:UISearchController = {
        var searchController:UISearchController!
        let tableVC =  UITableViewController(style: UITableViewStyle.Plain)
        tableVC.tableView.registerNib(UINib.init(nibName: "BasicTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "DecksCell")
        tableVC.tableView.dataSource = self
        tableVC.tableView.delegate = self
        tableVC.tableView.backgroundColor = UIColor.sb_Grey()
        
        searchController = UISearchController(searchResultsController: tableVC)
        searchController.searchBar.searchBarStyle = .Minimal
        searchController.searchBar.placeholder = "Szukaj talii"
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        return searchController
    }()

    var decksBar: UISearchBar {
        return searchController.searchBar
    }

    @IBOutlet weak var choosenDeckLabel: UILabel!
    @IBOutlet weak var searchBarWrapper: UIView!
    @IBOutlet weak var questionField: UITextField!
    @IBOutlet weak var tipField: UITextField!
    @IBOutlet weak var answerField: UITextField!
    
    private var flashcard:Flashcard!
    private var deck:Deck?
    
    var mode:EditFlashcardViewControllerMode! {
        didSet {
            if isViewLoaded() {
                updateUiForCurrentMode()
            }
        }
    }
    
    lazy private var dataManager:DataManager = {
        return UIApplication.appDelegate().dataManager
    }()
    
    lazy private var decks:[Deck] = {
        return self.dataManager.decks(true)
    }()
    
    var searchDecks:[Deck]?
    
    var decksTableViewSource:[Deck] {
        return searchDecks ?? decks
    }
    
    func clearInput(){
      
        decksBar.text = nil
        questionField.text = nil
        tipField.text = nil
        answerField.text = nil
        
    }
    
    private func updateUiForCurrentMode() {
        clearInput()
        switch mode {
        case .Modify(let card)?:
            flashcard = card
            deck = card.deck
            
            decksBar.text = card.deck?.name
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
            deck = nil
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(mode != nil, "mode not choosen!")
        searchBarWrapper.addSubview(decksBar)
        updateUiForCurrentMode()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !searchController.active {
            decksBar.frame.size.width = searchBarWrapper.frame.size.width
        }
    }
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        
        guard let answer = answerField.text, question = questionField.text else {
            presentAlertController(withTitle: "Błąd", message: "Pola odpowiedzi i pytania nie mogą być puste", buttonText: "Ok")
            return
        }
        
        guard let flashcardDeck = deck else {
            presentAlertController(withTitle: "Błąd", message: "Wybierz talię", buttonText: "Ok")
            return
        }
        
        var tip:Tip?
        if let tipText = tipField.text {
            tip = Tip.Text(text: tipText)
        }
        
        if case .Add? = mode {
            
            if let flashcardDeck = deck {
                do {
                    try dataManager.addFlashcard(forDeckWithId: flashcardDeck.id, question: question, answer: answer, tip: tip)

                } catch _ as DataManagerError {
                    presentAlertController(withTitle: "Błąd", message: "Nie udało się dodać fiszki", buttonText: "Ok")
                } catch let err {
                    print("EditFlashcardViewController adding error : \(err)")
                }

            }
        } else if case .Modify? = mode {
            
            flashcard.question = question
            flashcard.answer = answer
            flashcard.tipEnum = tip
            if flashcardDeck.id != flashcard.deckId {
                flashcard.deck? = flashcardDeck
            }
            
            do {
                try dataManager.updateFlashcard(flashcard)
            } catch _ as DataManagerError {
                presentAlertController(withTitle: "Błąd", message: "Nie udało się zapisać zmian", buttonText: "Ok")
            } catch let err {
                print("EditFlashcardViewController update error : \(err)")
            }
                
            
        }
        
        
    }
}


extension EditFlashcardViewController: UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decksTableViewSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DecksCell", forIndexPath: indexPath)
      
        let deck = decksTableViewSource[indexPath.row]
        
        cell.textLabel?.text = deck.uiName()

        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        searchDecks = decks.matching(searchController.searchBar.text)
        
        if let foundDecks = searchDecks where foundDecks.isEmpty {
            searchDecks = nil
        }
        (searchController.searchResultsController as? UITableViewController)?.tableView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        choosenDeckLabel.text = decksTableViewSource[indexPath.row].uiName()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        searchController.active = false 
    }
    
    

}