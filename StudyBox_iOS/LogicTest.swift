//
//  LogicTest.swift
//  StudyBox_iOS
//
//  Created by user on 06.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation


class FlashCard {
    
    private enum flashCardStatus {
        
        case success
        case fail
        case notTested
        
    }
    
    private var question : String
    private var answer : String
    private var prompt : String
    private var status : flashCardStatus
    
    
    init(question : String , answer : String , prompt : String) {
        self.question = question
        self.answer = answer
        self.prompt = prompt
        self.status = .notTested
    }
}


class Test {
    
    private var deck : [FlashCard]
    
    init(deck : [FlashCard]) {
        
        self.deck = deck
    }
    
    
    func currentFlashCard() -> FlashCard? {
        
        let size = UInt32(deck.capacity)
        var count = 0
        var rand : Int
        
        for card in deck {
            
            if( card.status != .notTested ) {
                count++
            }
            
        }
        if(count == deck.capacity) {
            
            return nil
            
        }
        else {
            
            repeat{
                
                rand = Int(arc4random_uniform(size))
                
            }while deck[rand].status != .notTested
            
            return deck[rand]
            
        }
        
    }
    
    
    func countFlashCardsSuccess() -> Int {
        
        var counter = 0
        
        for flashcard in deck{
            
            if (flashcard.status == .success) {
                counter++
            }
            
        }
        
        return counter
        
    }
    
    func IndexOfFlashCard() -> Int {
        
        var index = 0
        
        for flashcard in deck{
            
            if(flashcard.status != .notTested) {
                index++
            }
            
        }
        return index+1 /////fiszki po tescie + 1 aktualnie rozpatrywana
    }
    
    func statusOfFlashCard(card : FlashCard , status : Bool) {
        
        if(status == true){
            card.status = .success
        }
        else{
            card.status = .fail
        }
    }
    
    func currentDeck() -> [FlashCard]{
        
        return deck
        
    }
}