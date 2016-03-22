//
//  TestLogic.swift
//  StudyBox_iOS
//
//  Created by user on 12.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

enum TestLogicError:ErrorType {
    case PassedDeckIsEmpty , AllFlashcardsHidden
}

enum StudyType {
  case Test(uint), Learn
}

class Test {
  private var deck : [Flashcard]
  private(set) var currentCard : Flashcard?
  private var passedFlashcards = 0
  private var index = 0
  private var numberOfFlashcardsInFullDeck : Int
  private let testType : StudyType
  private let cardsInTest : Int
  // last 2 properties are made to determinate if passed deck was empty from the begginging 
  // or if all flashcards in passed deck was hidden
  private let passedDeckWasEmpty :Bool
  private let allFlashcardsMaybeHidden:Bool
  
  init(deck : [Flashcard], testType : StudyType) {
    
    // Checking if past deck was empty at the beggining
    if deck.isEmpty {
        passedDeckWasEmpty = true
    } else {
        passedDeckWasEmpty = false
    }
    
    // Making a temporary deck with only not hidden flashcards
    var tmpDeck: [Flashcard] = []
    for flashcard in deck{
        if (flashcard.hidden == false){
            tmpDeck.append(flashcard)
        }
    }
    
    
    self.deck = tmpDeck
    self.numberOfFlashcardsInFullDeck = deck.count
    self.testType = testType
    
    // This parameter helps function to determinate if all flashcards in passed deck are hidden.
    if numberOfFlashcardsInFullDeck == 0 {
        allFlashcardsMaybeHidden = true
    } else {
        allFlashcardsMaybeHidden = false
    }
    
    
    switch testType {
    case .Learn:
      cardsInTest = deck.count
    case .Test(let questionsNumber):
      if questionsNumber > uint(deck.count) {
        cardsInTest = deck.count
      } else {
        cardsInTest = Int(questionsNumber)
      }
    }
    
    newFlashcard(answeredCorrect:true)
  }
  
    
    
  /** Returns a tuple of numbers of flashcards that were answered correctly and how many flashcards are in the test
   - returns: `(passedFlashcards,cardsInTest)`
  */
  
    
  func cardsAnsweredAndPossible() -> (Int,Int) {
    return (passedFlashcards,cardsInTest)
  }
  
  /** Sets new flashcard and depending on `answeredCorrect` moves the card to end of deck
  - Parameter answeredCorrect: Was the last card marked correct or not
  - returns: Newly set `Flashcard?`; `nil` if no new `Flashcard` is there to set
  */
  func newFlashcard(answeredCorrect answeredCorrect:Bool) -> Flashcard? {
    var rand : Int
    
    if(cardsInTest == index) {
      currentCard = nil
    } else {
      rand = Int(arc4random_uniform(UInt32(deck.count)))
      currentCard = deck[rand]
      deck.removeAtIndex(rand)
      if !answeredCorrect{
        switch testType{
        case .Learn:
          //moves card to end of deck, if currentCard is not nil
          if let moveCardToEnd = currentCard {
            deck.append(moveCardToEnd)
          }
        case .Test(uint(cardsInTest)):
          break
        default:
          break
        }
      }
    }
    index += 1
    
    return currentCard
  }
  
  // Function is checking if all of flashcards in test are hidden
  func checkIfAllFlashcardsHidden() throws {
    if passedDeckWasEmpty == false && allFlashcardsMaybeHidden == true {
        throw TestLogicError.AllFlashcardsHidden
    }
  }
  /// Function is checking if passed deck was empty at the beginning
  func checkIfPassedDeckIsEmpty() throws {
    if passedDeckWasEmpty {
        throw TestLogicError.PassedDeckIsEmpty
    }
  }
  ///Function to call when user taps "correct" button, sets a new flashcard and increments `passedFlashcards`
  func correctAnswer() {
    passedFlashcards += 1
    newFlashcard(answeredCorrect:true)
  }
  
  ///Function to call when user taps "incorrect" button, and moves `currentCard` to end of deck
  func incorrectAnswer(testType:StudyType) {
    newFlashcard(answeredCorrect:false)
  }
}