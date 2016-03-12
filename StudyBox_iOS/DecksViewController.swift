//
//  DecksViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit


class DecksViewController: StudyBoxViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var decksArray: [Deck]?
    static private(set) var selectedDeckForTesting: Deck?
    @IBOutlet var decksCollectionView: UICollectionView!
    
    // TODO: in future replace managerWithDummyData()
    override func viewWillAppear(animated: Bool) {
        DecksViewController.selectedDeckForTesting(changeWithDeck: nil)
        let dataManager = DataManager.managerWithDummyData()
        decksArray = dataManager.decks(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decksCollectionView.delegate = self
        decksCollectionView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    // Before segue do this
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StartTest" {
            if let _ = segue.destinationViewController as? TestViewController {
                // destinationTestView.currentDeckForTesting = selectedDeck
            }
        }
    }
    */
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Calculate number of decks. If no decks, return 0
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var cellsNumber = 0
        if let decksArrayCount = decksArray?.count{
            cellsNumber = decksArrayCount
        }
        return cellsNumber
    }
    
    // Populate cells with decks data. Change cells style
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Utils.UIIds.DecksViewCellID, forIndexPath: indexPath)
            as! DecksViewCell

        if let deckName = decksArray?[indexPath.row].name{
            cell.deckNameLabel.text = deckName
        }
        cell.deckNameLabel.font = UIFont.sbFont(bold: false)
        return cell
    }
    
    // When cell tapped, change to test
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let notNilDecksArray = decksArray{
            DecksViewController.selectedDeckForTesting(changeWithDeck: notNilDecksArray[indexPath.row])
        }

        // self.performSegueWithIdentifier("StartTest", sender: nil)
        if let test = storyboard?.instantiateViewControllerWithIdentifier(Utils.UIIds.TestViewControllerID) {
            navigationController?.viewControllers = [ test ]
        }
    }
 
    // Change static property selectedDeckForTesting
    private class func selectedDeckForTesting(changeWithDeck deck: Deck?){
        DecksViewController.selectedDeckForTesting = deck
    }
}
