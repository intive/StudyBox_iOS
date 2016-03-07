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
        // tutaj zmiana koloru
        // view.backgroundColor = UIColor.redColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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
    
    // MARK: Change view to test
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // ustawianie wybranej talii
        // let selectedDeck = decksArray[indexPath.row]
        // Coś w stylu: TestViewController.actualTest = selectedDeck
        let testView = storyboard?.instantiateViewControllerWithIdentifier("TestViewControllerID")
        let testNavigation = UINavigationController(rootViewController: testView!)
        self.presentViewController(testNavigation, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DecksViewCellID", forIndexPath: indexPath)
            as! DecksViewCell
        cell.deckNameLabel.font = UIFont.studyBoxBlack()
        // czeka na Kolory
        // cell.backgroundColor = UIColor.redColor() - niestety takie coś nie działa, trzeba innego sposobu na zmianę koloru komórki
    }
}
