//
//  RandomDeckLoadingController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 15.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import Reachability
import SVProgressHUD

class RandomDeckLoadingController: StudyBoxViewController {
    
    @IBOutlet weak var statusLabelOutlet: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    var flashcards = [Flashcard]()
    
    var dataManager = UIApplication.appDelegate().dataManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabelOutlet.hidden = true
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
        SVProgressHUD.show()
        statusLabelOutlet.hidden = true
        retryButton.hidden = true
    }
    
    @IBAction func retryAction(sender: AnyObject) {
        SVProgressHUD.show()
        if !Reachability.isConnected() {
            SVProgressHUD.dismiss()
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
                            SVProgressHUD.dismiss()
                            self.performSegueWithIdentifier("StartTest",
                                sender: Test(flashcards: flashcards, testType: .Test(uint(flashcards.count)), deck: recievedDeck))
                        }
                    case .Error(let err):
                        debugPrint(err)
                        self.updateUI(message: "Błąd pobierania fiszek.")
                    }
                })
                
            case .Error(let err):
                debugPrint(err)
                self.updateUI(message: "Błąd pobierania talii.")
            }
        })
    }
    
    func updateUI(message message: String) {
        statusLabelOutlet.text = message
        statusLabelOutlet.hidden = false
        retryButton.hidden = false
        SVProgressHUD.dismiss()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StartTest", let testViewController = segue.destinationViewController as? TestViewController, testLogic = sender as? Test {
            testViewController.testLogicSource = testLogic
        }
    }
    
}
