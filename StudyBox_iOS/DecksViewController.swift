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
    private var searchDecks: [Deck]?
    
    @IBOutlet var decksCollectionView: UICollectionView!
    private var searchBar:UISearchBar?
 
    var isSearchBarVisible = false
    
    lazy private var statusBarHeight:CGFloat = {
        return UIApplication.sharedApplication().statusBarFrame.height
    }()
    
    lazy private var navbarHeight:CGFloat = {
        if let height = self.navigationController?.navigationBar.frame.height {
            return height
        }
        return 0
    }()
    
    /**
     * CollectionView content offset is determined by status bar and navigation bar height
    */
    lazy private var topItemOffset:CGFloat = {
        return -(self.statusBarHeight + self.navbarHeight)
    }()
    
    private var searchBarHeight:CGFloat = 44
    private var marginValue:CGFloat = 8

    private var softAnimationDuration = 0.2
    private var accurateAnimationDuration = 0.5
    
    // TODO: in future replace managerWithDummyData()
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DecksViewController.selectedDeckForTesting = nil
        let dataManager = DataManager.managerWithDummyData()
        decksArray = dataManager.decks(false)
        setupSearchBar()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        setupSearchBar()
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
        if let searchDecksCount = searchDecks?.count{
            cellsNumber = searchDecksCount
        }else if let decksCount = decksArray?.count {
            cellsNumber = decksCount
        }
        return cellsNumber
    }
    
    // Populate cells with decks data. Change cells style
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var source:[Deck]?
        if searchDecks != nil {
            source = searchDecks
        }else {
            source = decksArray
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Utils.UIIds.DecksViewCellID, forIndexPath: indexPath)
            as! DecksViewCell
        
        cell.layoutIfNeeded()

        if var deckName = source?[indexPath.row].name{
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
        if let decks = searchDecks {
            DecksViewController.selectedDeckForTesting = decks[indexPath.row]
        }else if let notNilDecksArray = decksArray {
            DecksViewController.selectedDeckForTesting = notNilDecksArray[indexPath.row]
        }
        if let test = storyboard?.instantiateViewControllerWithIdentifier(Utils.UIIds.TestViewControllerID) {
            cancelSearchReposition(searchBar!, animated: false)
            navigationController?.viewControllers = [ test ]
        }
    }
 
}

// MARK: UISearchBar implementaton
extension DecksViewController: UISearchBarDelegate {
    
    func setupSearchBar() {
        
        if (searchBar == nil) {
            
            searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: searchBarHeight))
            searchBar?.searchBarStyle = .Default
            searchBar?.tintColor = UIColor.whiteColor()
            searchBar?.placeholder = "Talie"
            searchBar?.delegate = self
            
            if let bar = searchBar {
                view.insertSubview(bar, aboveSubview: decksCollectionView)
            }
            
        }else {
            if (searchBar?.delegate != nil) {
                searchBar?.delegate = nil
            }else {
                searchBar?.delegate = self
            }
        }
    }
    
    func cancelSearchReposition(searchBar:UISearchBar,animated:Bool) {
        searchDecks = nil
        decksCollectionView.reloadData()
        
        searchBar.text = nil
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: animated)
        
        if animated {
            UIView.beginAnimations("cancel", context: nil)
            UIView.setAnimationDelay(0)
            UIView.setAnimationDuration(accurateAnimationDuration)
            UIView.setAnimationCurve(.EaseOut)
            
        }
        
        if let navigation = navigationController?.navigationBar {
            
            let top = self.topItemOffset - self.searchBarHeight
            
            self.decksCollectionView.contentInset = UIEdgeInsets(top: -top, left: 0, bottom: 0, right: 0)
            self.decksCollectionView.contentOffset.y = top
            
            navigation.frame.origin.y = self.statusBarHeight
            
            searchBar.frame = CGRect(x: 0, y: -self.topItemOffset, width: searchBar.frame.width, height: self.searchBarHeight)
        }
        
        if animated {
            UIView.commitAnimations()
        }
        
        
    }
    
    func startSearchReposition(searchBar:UISearchBar,animated:Bool) {
        
        searchBar.setShowsCancelButton(true, animated: true)
        
        if animated {
            UIView.beginAnimations("cancel", context: nil)
            UIView.setAnimationDelay(0)
            UIView.setAnimationDuration(accurateAnimationDuration)
            UIView.setAnimationCurve(.EaseOut)
            
        }
        if let navigation = navigationController?.navigationBar {
            
            navigation.frame.origin.y = -navigation.frame.height
            
            searchBar.frame.origin.y = 0
            searchBar.frame.size.height = self.searchBarHeight + self.statusBarHeight
    
            self.decksCollectionView.contentInset = UIEdgeInsets(top: self.searchBarHeight + self.statusBarHeight + self.marginValue, left: 0, bottom: 0, right: 0)
        }
        
        if animated {
            UIView.commitAnimations()
        }
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            searchDecks = decksArray?.filter {
                return $0.name.containsString(searchText)
                }.sort {
                    return $0.0.name < $0.1.name
            }
            
        }else {
            searchDecks = nil
        }
        
        decksCollectionView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        cancelSearchReposition(searchBar, animated: true)
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        startSearchReposition(searchBar, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < topItemOffset) {
            
            if (!isSearchBarVisible) {
                isSearchBarVisible = true
                decksCollectionView.contentInset = UIEdgeInsets(top: searchBarHeight - topItemOffset, left: 0, bottom: 0, right: 0)
                
                UIView.animateWithDuration(softAnimationDuration, delay: 0, options: .CurveEaseOut,
                    animations: {
                        self.searchBar?.frame.origin.y = -self.topItemOffset
                    },
                    completion: nil
                )
            }
        }else {
            isSearchBarVisible = false
            decksCollectionView.contentInset = UIEdgeInsets(top: -topItemOffset, left: 0, bottom: 0, right: 0)
            
            UIView.animateWithDuration(softAnimationDuration, delay: 0, options: .CurveEaseOut,
                animations: {
                    self.searchBar?.frame.origin.y = 0
                },
                completion: nil
            )
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
