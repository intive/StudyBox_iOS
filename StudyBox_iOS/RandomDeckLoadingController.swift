//
//  RandomDeckLoadingController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 15.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import Reachability

class RandomDeckLoadingController: StudyBoxViewController {
    
    @IBOutlet weak var loadingLabelOutlet: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    var flashcards = [Flashcard]()

    var dataManager = UIApplication.appDelegate().dataManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingLabelOutlet.text = "Ładowanie..."
        retryButton.hidden = true
        
        if !Reachability.isConnected() {
            updateUI(message: "Nie jesteś połączony z Internetem.")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        recieveFlashcardsAndPerformSegue()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadingLabelOutlet.text = "Ładowanie..."
        retryButton.hidden = true
    }
    
    @IBAction func retryAction(sender: AnyObject) {
        if !Reachability.isConnected() {
            updateUI(message: "Nie jesteś połączony z Internetem.")
        } else {
            recieveFlashcardsAndPerformSegue()
        }
    }
    
    func recieveFlashcardsAndPerformSegue() {
        
        dataManager.randomDeck({ deckResponse in
            switch deckResponse {
            case .Success(let recievedDeck):
                self.dataManager.flashcards(recievedDeck.serverID, completion: { flashcardsResponse in
                    switch flashcardsResponse {
                    case .Success(let flashcards):
                        if flashcards.isEmpty {
                            self.updateUI(message: "Otrzymano pustą talię.")
                        } else {
                            self.performSegueWithIdentifier("StartTest",
                                sender: Test(deck: flashcards, testType: .Test(uint(flashcards.count)),
                                    deckName: recievedDeck.name, deckAuthor: recievedDeck.owner))
                        }
                    case .Error(let err):
                        print(err)
                        self.updateUI(message: "Błąd pobierania fiszek.")
                    }
                })
                
            case .Error(let err):
                print(err)
                self.updateUI(message: "Błąd pobierania talii.")
            }
        })
    }
    
    func updateUI(message message: String) {
            loadingLabelOutlet.text = message
            retryButton.hidden = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StartTest", let testViewController = segue.destinationViewController as? TestViewController, testLogic = sender as? Test {
            testViewController.testLogicSource = testLogic
        }
    }
    
}
