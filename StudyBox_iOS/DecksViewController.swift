//
//  DecksViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class DecksViewController: StudyBoxViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    // czeka na DataModel
    // private var decksArray: [Deck]?
    @IBOutlet var decksCollectionView: UICollectionView!
    
    override func viewDidAppear(animated: Bool) {
        // czeka na DataModel
        // Coś w stylu: decksArray = Deck.loadDecks().map{$0 < $1}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decksCollectionView.delegate = self
        decksCollectionView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Before segue do this
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StartTest" {
            if let _ = segue.destinationViewController as? TestViewController {
                // destinationTestView.currentDeckForTesting = selectedDeck
            }
        }
    }
    
    // Populate cells
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // czeka na DataModel
        // return decksArray.count
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DecksViewCellID", forIndexPath: indexPath)
            as! DecksViewCell
        // czeka na DataModel
        // Coś w stylu: cell.deckNameLabel.text = decksArray[indexPath.row].name
        cell.deckNameLabel.text = "Przykład"
        
        return cell
    }
    
    // When cell tapped, change to test
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // ustawianie wybranej talii
        // let selectedDeck = decksArray[indexPath.row]
        // Coś w stylu: TestViewController.actualTest = selectedDeck
        self.performSegueWithIdentifier("StartTest", sender: nil)
    }
    
    // Change cell color and font
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DecksViewCellID", forIndexPath: indexPath)
            as! DecksViewCell
        cell.deckNameLabel.font = UIFont.studyBoxBlack()
        // tu można jeszcze zmienić kolor
    }
}
