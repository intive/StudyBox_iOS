//
//  DecksViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit


class DecksViewController: StudyBoxViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // points selected deck
    static private(set) var selectedDeckForTesting: Deck?
    
    private var decksArray: [Deck]?
    @IBOutlet var decksCollectionView: UICollectionView!
    
    // TODO: in future replace managerWithDummyData()
    override func viewWillAppear(animated: Bool) {
        DecksViewController.selectedDeckForTesting = nil
        let dataManager = DataManager.managerWithDummyData()
        decksArray = dataManager.decks(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decksCollectionView.delegate = self
        decksCollectionView.dataSource = self
        
        let layout = decksCollectionView.collectionViewLayout
        let flow = layout as! UICollectionViewFlowLayout
        let spacing = Utils.DeckViewLayout.DecksSpacing
        equalSizeAndSpacing(numberOfCellsInRow: Utils.DeckViewLayout.DecksInRowIPhoneVer, spacing: spacing, collectionFlowLayout: flow)
        
        decksCollectionView.backgroundColor = UIColor.whiteColor()

    }
    
    // this function calculate size of decks, by given spacing and number of cells in row
    private func equalSizeAndSpacing(numberOfCellsInRow crNumber: CGFloat, spacing: CGFloat,
        collectionFlowLayout flow: UICollectionViewFlowLayout){
            
        let screenSize = self.view.bounds.size
        let deckWidth = screenSize.width/crNumber - (spacing + spacing/crNumber)
        flow.sectionInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        // spacing between decks
        flow.minimumInteritemSpacing = spacing
        // spacing between rows
        flow.minimumLineSpacing = spacing
        // size for every deck
        flow.itemSize = CGSize(width: deckWidth, height: deckWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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
        
        cell.layoutIfNeeded()

        if var deckName = decksArray?[indexPath.row].name{
            if deckName.isEmpty {
                deckName = Utils.DeckViewLayout.DeckWithoutTitle
            }
            cell.deckNameLabel.text = deckName
        }
        // changing label UI
        cell.deckNameLabel.adjustFontSizeToHeight(UIFont.sbFont(size: sbFontSizeLarge, bold: false), max: sbFontSizeLarge, min: sbFontSizeSmall)
        cell.deckNameLabel.textColor = UIColor.whiteColor()
        cell.deckNameLabel.numberOfLines = 0
        // adding line breaks
        cell.deckNameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.deckNameLabel.preferredMaxLayoutWidth = cell.bounds.size.width
        cell.contentView.backgroundColor = UIColor.sb_Graphite()
        
        return cell
    }
    
    // When cell tapped, change to test
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let notNilDecksArray = decksArray{
            DecksViewController.selectedDeckForTesting = notNilDecksArray[indexPath.row]
        }

        if let test = storyboard?.instantiateViewControllerWithIdentifier(Utils.UIIds.TestViewControllerID) {
            navigationController?.viewControllers = [ test ]
        }
    }
 
}

// this extension dynamically change the size of the fonts, so text can fit
extension UILabel {
    func adjustFontSizeToHeight(var font: UIFont, max:CGFloat, min:CGFloat)
    {
        // Initial size is max and the condition the min.
        for var size = max ; size >= min ; size -= 0.1
        {
            
            font = font.fontWithSize(size)
            let attrString = NSAttributedString(string: self.text!, attributes: [NSFontAttributeName : font])
            let rectSize = attrString.boundingRectWithSize(CGSizeMake(self.bounds.width, CGFloat.max), options: .UsesLineFragmentOrigin, context: nil)
            
            if rectSize.size.height <= self.bounds.height
            {
                self.font = font
                break
            }

        }
        // in case, it is better to have the smallest possible font
        self.font = font
    }
}
