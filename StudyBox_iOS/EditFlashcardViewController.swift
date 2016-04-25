//
//  EditFicheViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

enum EditFlashcardViewControllerMode {
    case Add, Modify(flashcard: Flashcard, updateCallback: ((flashcard: Flashcard) -> Void)?)
}

class EditFlashcardViewController: StudyBoxViewController {
    
    @IBOutlet weak var searchbarWrapperTopConstraint: NSLayoutConstraint!

    var dummySearchController: UISearchController?
    
    var searchController: UISearchController!  {
        if dummySearchController == nil {
            dummySearchController = setupSearchController()
        }
        return dummySearchController
    }

    var decksBar: UISearchBar {
        return searchController.searchBar
    }

    @IBOutlet weak var choosenDeckLabel: UILabel!
    @IBOutlet weak var searchBarWrapper: UIView!
    @IBOutlet weak var questionField: UITextField!
    @IBOutlet weak var tipField: UITextField!
    @IBOutlet weak var answerField: UITextField!
    
    private var flashcard: Flashcard!
    private var deck: Deck?
    
    var mode: EditFlashcardViewControllerMode! {
        didSet {
            if isViewLoaded() {
                updateUiForCurrentMode()
            }
        }
    }
    
    lazy private var dataManager: DataManager = {
        return UIApplication.appDelegate().dataManager
    }()
    
    lazy private var decks: [Deck] = {
        return self.dataManager.decks(true)
    }()
    
    var searchDecks: [Deck]?
    
    func setupSearchController() -> UISearchController {
        let tableVC =  UITableViewController(style: UITableViewStyle.Plain)
        tableVC.tableView.registerNib(UINib.init(nibName: "BasicTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "DecksCell")
        tableVC.tableView.dataSource = self
        tableVC.tableView.delegate = self
        tableVC.tableView.backgroundColor = UIColor.sb_Grey()
        
        let searchController = UISearchController(searchResultsController: tableVC)
        searchController.searchBar.searchBarStyle = .Minimal
        searchController.searchBar.placeholder = "Szukaj talii"
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        if isViewLoaded() {
            searchController.searchBar.sizeToFit()
            searchBarWrapper.addSubview(searchController.searchBar)
        }
        definesPresentationContext = true
        return searchController
    }
    
    func clearInput(){
      
        decksBar.text = nil
        questionField.text = nil
        tipField.text = nil
        answerField.text = nil
        deck = nil
        choosenDeckLabel.text = "Wybrana talia"
    }
    
    private func updateUiForCurrentMode() {
        clearInput()
        switch mode {
        case .Modify(let card, _)?:
            flashcard = card
            deck = card.deck
            choosenDeckLabel.text = card.deck?.uiName
            questionField.text = card.question
            tipField.text = card.tip
            answerField.text = card.answer
            navigationItem.title = "Edytuj"
            if presentingViewController != nil {
                navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelEdition))
            }
            searchBarWrapper.hidden = true
            searchbarWrapperTopConstraint.constant = -searchBarWrapper.frame.height
            view.layoutIfNeeded()
        case .Add?:
            navigationItem.title = "Stwórz"
            searchBarWrapper.hidden = false
            searchbarWrapperTopConstraint.constant = 0
            flashcard = nil
        default:
            navigationItem.title = nil
            flashcard = nil
            deck = nil
        }
        
    }
    
    func cancelEdition() {
        let alert = UIAlertController(title: "Przerwij", message: "Czy na pewno chcesz przerwać edycję fiszki?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Tak", style: .Default, handler: { (_) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Nie", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func disposeResources(isVisible: Bool) {
        super.disposeResources(isVisible)
        if !isVisible {
            dummySearchController?.searchBar.removeFromSuperview()
            dummySearchController = nil
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(mode != nil, "mode not choosen!")
        
        clearInput()
        updateUiForCurrentMode()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchBarWrapper.addSubview(decksBar)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.view.removeFromSuperview()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dummySearchController?.searchBar.sizeToFit()
    }
    @IBAction func saveAction(sender: UIBarButtonItem) {
        
        guard let answer = answerField.text, question = questionField.text where !answer.isEmpty && !question.isEmpty else {
            presentAlertController(withTitle: "Błąd", message: "Pola odpowiedzi i pytania nie mogą być puste", buttonText: "Ok")
            return
        }
        
        guard let flashcardDeck = deck else {
            presentAlertController(withTitle: "Błąd", message: "Wybierz talię", buttonText: "Ok")
            return
        }
        
        var tip: Tip?
        if let tipText = tipField.text {
            tip = Tip.Text(text: tipText)
        }
        
        if case .Add? = mode {
            
            if let flashcardDeck = deck {
                do {
                    try dataManager.addFlashcard(forDeckWithId: flashcardDeck.serverID, question: question, answer: answer, tip: tip)
                    presentAlertController(withTitle: "Sukces", message: "Dodano fiszkę", buttonText: "Ok")
                    clearInput()
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
            if flashcardDeck.serverID != flashcard.deckId {
                flashcard.deck? = flashcardDeck
            }
            let completion = {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            do {
                try dataManager.updateFlashcard(flashcard)
                
                
                presentAlertController(withTitle: "Sukces", message: "Zaktualizowano fiszkę", buttonText: "Ok",
                                       actionCompletion: completion,
                                       dismissCompletion: nil)
            } catch _ {
                presentAlertController(withTitle: "Błąd", message: "Nie udało się zapisać zmian", buttonText: "Ok",
                                       actionCompletion: completion,
                                       dismissCompletion: nil)
            }
            if let mode = mode {
                if case let EditFlashcardViewControllerMode.Modify( _, callback) = mode {
                    callback?(flashcard:flashcard)
                }
            }
        }
        
    }
}


extension EditFlashcardViewController: UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchDecks?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DecksCell", forIndexPath: indexPath)
      
        let deck = searchDecks?[indexPath.row]
        
        cell.textLabel?.text = deck?.uiName

        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        searchDecks = decks.matching(searchController.searchBar.text)
        
        if let foundDecks = searchDecks where foundDecks.isEmpty {
            searchDecks = nil
        }
        if let tableController = searchController.searchResultsController as? UITableViewController {
            tableController.tableView.reloadData()
        }
        
    }
    func didDismissSearchController(searchController: UISearchController) {
        searchController.searchBar.sizeToFit()

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        deck = searchDecks?[indexPath.row]
        choosenDeckLabel.text = searchDecks?[indexPath.row].uiName
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        searchController.active = false
    }
    

}
