//
//  DecksViewController+dataSource.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 29.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import SVProgressHUD

extension DecksViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        if decksSource.isEmpty && (UIApplication.isUserLoggedIn || searchController.active){
            return CGSize(width: collectionView.frame.width, height: view.frame.height + topItemOffset)
        }
        
        return  CGSize.zero
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                                 atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionFooter:
            guard let emptyView = collectionView
                .dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "EmptyView", forIndexPath: indexPath) as? EmptyCollectionReusableView else {
                    fatalError("Incorrect supplementary view type")
            }
            if searchController.active {
                emptyView.messageLabel.text = emptySearch ? "Wpisz szukaną frazę" : "Nie znaleziono talii o podanej nazwie"
                
            } else {
                emptyView.messageLabel.text = "Nie dodałeś jeszcze żadnej talii"
            }
            return emptyView
        default:
            fatalError("Unexpected collection element")
            
        }
    }

    private func withDummySearchingCell() -> Bool {
        return !searchController.active && !UIApplication.isUserLoggedIn
  
    }
    
    // Calculate number of decks. If no decks, return 0
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if withDummySearchingCell() {
            return decksSource.count + 1
        }
        return decksSource.count
    }
    
    // Populate cells with decks data. Change cells style
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let view = collectionView.dequeueReusableCellWithReuseIdentifier(Utils.UIIds.DecksViewCellID, forIndexPath: indexPath)
        if let cell = view as? DecksViewCell{
            
            // setup UI reagardless of cell type
            defer {
                cell.deckNameLabel.numberOfLines = 0
                // adding line breaks
                cell.deckNameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                cell.deckNameLabel.preferredMaxLayoutWidth = cell.bounds.size.width
                if let font = UIFont.sbFont(size: sbFontSizeLarge, bold: false) {
                    cell.deckNameLabel.adjustFontSizeToHeight(font, max: sbFontSizeLarge, min: sbFontSizeSmall)
                }
                
            }
            cell.layoutIfNeeded()
            
            
            cell.contentView.backgroundColor = UIColor.sb_Graphite()
            
            if withDummySearchingCell() {
                if indexPath.row == decksSource.count  {
                    cell.contentView.backgroundColor = UIColor.sb_White()
                    cell.setupBorderLayer()
                    cell.deckNameLabel.textColor = UIColor.sb_Graphite()
                    cell.deckNameLabel.text = "Przesuń w dół aby wyszukać więcej talii"
                    cell.deckFlashcardsCountLabel.text = nil 
                    return cell
                }
            }
            
            cell.deckNameLabel.textColor = UIColor.whiteColor()
            
            var deckName = decksSource[indexPath.row].0.name
            if deckName.isEmpty {
                deckName = Utils.DeckViewLayout.DeckWithoutTitle
            }
            let deckFlashcardsCount = decksSource[indexPath.row].1
            cell.deckNameLabel.text = deckName
            cell.deckFlashcardsCountLabel.text = String(deckFlashcardsCount)
            cell.deckFlashcardsCountLabel.textColor = UIColor.whiteColor()
            if let countFont = UIFont.sbFont(size: sbFontSizeSmall, bold: false){
                cell.deckFlashcardsCountLabel.font = countFont
            }
            cell.removeBorderLayer()
            return cell
        }
        return view
    }
    
    // When cell tapped, change to test
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == decksSource.count {
            collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.contentInset.top), animated: true)
            return
        }
        
        SVProgressHUD.show()
        let deck = decksSource[indexPath.row].0
        searchBar.resignFirstResponder()
        let resetSearchUI = {
            self.searchController.active = false
        }
        
        dataManager.flashcards(deck.serverID) {
            switch $0 {
            case .Success(let flashcards):
                guard !flashcards.isEmpty else {
                    SVProgressHUD.showInfoWithStatus("Talia nie ma fiszek.")
                    return
                }
                
                let amountFlashcardsNotHidden = flashcards.reduce(0) { ret, flashcard in flashcard.hidden ? ret : ret + 1}
                
                guard amountFlashcardsNotHidden != 0 else {
                    SVProgressHUD.showInfoWithStatus("Talia ma ukryte wszystkie fiszki.")
                    return
                }
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Test czy nauka?", message: "Wybierz tryb, który chcesz uruchomić", preferredStyle: .Alert)
                
                let testButton = UIAlertAction(title: "Test", style: .Default){ (alert: UIAlertAction!) -> Void in
                    let alertAmount = UIAlertController(title: "Jaka ilość fiszek?", message: "Wybierz ilość fiszek w teście", preferredStyle: .Alert)
                    
                    let amounts = [ 1, 5, 10, 15, 20 ]
                    
                    for amount in amounts {
                        if amount < amountFlashcardsNotHidden {
                            alertAmount.addAction(UIAlertAction(title: String(amount), style: .Default) { act in
                                resetSearchUI()
                                self.performSegueWithIdentifier("StartTest",
                                    sender: Test(flashcards: flashcards, testType: .Test(UInt32(amount)), deck: deck))
                                })
                        } else {
                            break
                        }
                    }
                    alertAmount.addAction(UIAlertAction(title: "Wszystkie (" + String(amountFlashcardsNotHidden) + ")", style: .Default) { act in
                        resetSearchUI()
                        self.performSegueWithIdentifier("StartTest",
                            sender: Test(flashcards: flashcards, testType: .Test(UInt32(amountFlashcardsNotHidden)), deck: deck))
                        })
                    alertAmount.addAction(UIAlertAction(title: "Anuluj", style: UIAlertActionStyle.Cancel, handler: nil))
                    
                    self.presentViewController(alertAmount, animated: true, completion:nil)
                }
                let studyButton = UIAlertAction(title: "Nauka", style: .Default) { (alert: UIAlertAction!) -> Void in
                    resetSearchUI()
                    self.performSegueWithIdentifier("StartTest", sender: Test(flashcards: flashcards, testType: .Learn, deck: deck))
                }
                
                alert.addAction(testButton)
                alert.addAction(studyButton)
                alert.addAction(UIAlertAction(title: "Anuluj", style: UIAlertActionStyle.Cancel, handler: nil))
                
                self.presentViewController(alert, animated: true, completion:nil)
                
            case .Error(_):
                SVProgressHUD.showErrorWithStatus("Nie udało się pobrać danych.")
            }
        }
    }
}
