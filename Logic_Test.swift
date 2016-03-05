//
//  Logic_Test.swift
//  StudyBox_iOS
//
//  Created by user on 04.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

class FlashCard {
    
    private var question : String
    private var answer : String
    private var prompt : String
    private var knowable = 0 ////////// 0 - nieznana/przed testem 1 - po tescie / znana 2 - po tescie/nieznana
    
    init(question : String , answer : String , prompt : String) {
        self.question = question
        self.answer = answer
        self.prompt = prompt
    }
}


class Test {
    
    private var deck : [FlashCard]
    
    init(deck : [FlashCard]) {
        
        self.deck = deck
    }
    
    func ReturnFlashCard() -> FlashCard {
        
        var rand = Int(arc4random_uniform(20))
        
        while deck[rand].knowable != 0 {
            rand = Int(arc4random_uniform(20))
        }
        
        return deck[rand]
    }
    
    
    func CountFlashCardsPass() -> Int {
        var counter = 0
        
        for var i = 0 ; i < 20 ; i++ {
            
            if(deck[i].knowable == 1) {
                counter++
            }
            
        }
        
        return counter
        
    }
    
    func ReturnIndexOfFlashCard() -> Int {
        
        var index = 0
        for var i = 0 ; i < 20 ; i++ {
            
            if(deck[i].knowable != 0) {
                index++
            }
            
        }
        return index+1 /////fiszki po tescie + 1 aktualnie rozpatrywana
    }
    
    func StatusOfFlashCard(card : FlashCard , status : Bool) {
        
        if(status == true){
            card.knowable = 1//sukces
        }
        else{
            card.knowable = 2//porazka
        }
    }
    
    func ReturnDeck() -> [FlashCard]{
        
        return deck
        
    }
}