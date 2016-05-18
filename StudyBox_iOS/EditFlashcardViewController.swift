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

class EditFlashcardViewController: StudyBoxViewController, UITextViewDelegate {
    
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
    
    var currentlyEditedTextView: UITextView?

    @IBOutlet weak var choosenDeckLabel: UILabel!
    @IBOutlet weak var searchBarWrapper: UIView!
    @IBOutlet weak var questionField: UIPlaceholderTextView!
    @IBOutlet weak var answerField: UIPlaceholderTextView!
    @IBOutlet var editFields: [UITextView]!
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    
    private var decks: [Deck] = [Deck]()
    
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
        alert.addAction(UIAlertAction(title: "Nie", style: .Default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Tak", style: .Default, handler: { (_) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
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
        answerField.placeholder = "Odpowiedź"
        questionField.placeholder = "Pytanie"
        updateUiForCurrentMode()

        let graphite = UIColor.sb_Graphite().CGColor
        for field in editFields {
            field.layer.borderColor = graphite
            field.layer.borderWidth = 1
            field.layer.cornerRadius = 10
            field.delegate = self
        }
        scrollView.delegate = self
    }
    
    func keyboardWillHide() {
        scrollView.contentInset.bottom = 0
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() {
            if let mmDrawer = mm_drawerController {
                guard  mmDrawer.openSide == .None else {
                    return
                }
            }
            guard frame.size.height > 0, let textView = currentlyEditedTextView else {
                return
            }
            scrollView.contentInset.bottom = frame.size.height
            
            let yPosition = scrollView.frame.origin.y + textView.frame.origin.y
            
            let bottom = yPosition + textView.frame.height + 8
            if bottom > frame.origin.y {
                scrollView.setContentOffset(CGPoint(x: 0, y: bottom - frame.origin.y), animated: true)
            } else if scrollView.contentOffset.y > textView.frame.origin.y {
                scrollView.setContentOffset(CGPoint(x: 0, y: textView.frame.origin.y), animated: true)
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataManager.decks {
            switch $0 {
            case .Success(let decks):
                self.decks = decks
            case .Error(_):
                self.presentAlertController(withTitle: "Błąd", message: "Nie udało się pobrać aktualnej listy talii", buttonText: "Ok")
            }
        }
        searchBarWrapper.addSubview(decksBar)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
 
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.view.removeFromSuperview()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dummySearchController?.searchBar.sizeToFit()
    }
    func textViewDidEndEditing(textView: UITextView) {
        currentlyEditedTextView = nil
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        currentlyEditedTextView = textView
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        currentlyEditedTextView?.endEditing(true)
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
        
        guard let mode = mode else {
            return
        }
        
        if case .Add = mode {
            
            dataManager.addFlashcard(Flashcard(deckID: flashcardDeck.serverID, question: question, answer: answer, isHidden: false)) {
                switch $0 {
                case .Success(_):
                    self.presentAlertController(withTitle: "Sukces", message: "Dodano fiszkę", buttonText: "Ok")
                    self.clearInput()
                case .Error(_):
                    self.presentAlertController(withTitle: "Błąd", message: "Nie udało się dodać fiszki", buttonText: "Ok")
                    
                }
            }

        } else if case .Modify(_, let callback) = mode {
            modifyAction(question, answer: answer, callback: callback)
            
        }
        
    }
    
    private func modifyAction(question: String, answer: String, callback: ((flashcard: Flashcard) -> Void)?) {
        let updateFlashcardCpy = Flashcard(serverID: flashcard.serverID, deckID: flashcard.deckId, question: question, answer: answer, isHidden: false)
        let completion = {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        dataManager.updateFlashcard(updateFlashcardCpy) {
            switch $0 {
            case .Success(let updatedFlashcard):
                callback?(flashcard:updatedFlashcard)
                self.presentAlertController(withTitle: "Sukces", message: "Zaktualizowano fiszkę", buttonText: "Ok",
                                            actionCompletion: completion,
                                            dismissCompletion: nil)
            case .Error(let err):
                var errMessage = "Nie udało się zapisać zmian"
                if case ServerError.ErrorWithMessage(let serverErrMessage) = err {
                    errMessage = serverErrMessage
                }
                
                self.presentAlertController(withTitle: "Błąd", message: errMessage, buttonText: "Ok",
                                            actionCompletion: completion,
                                            dismissCompletion: nil)
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
