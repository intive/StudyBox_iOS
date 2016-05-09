//
//  DecksViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class DecksViewController: StudyBoxCollectionViewController, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout, DecksCollectionLayoutDelegate {
    
    var searchBarWrapper: UIView!
    var searchBarTopConstraint: NSLayoutConstraint!
    var searchController: UISearchController = UISearchController(searchResultsController: nil)

    var searchBar: UISearchBar {
        return searchController.searchBar
    }
    
    var decksArray: [Deck]?
    var searchDecks: [Deck]?
    
    var decksSource: [Deck]? {
        return searchDecks ?? decksArray
    }
    
    lazy var dataManager: NewDataManager = {
        return UIApplication.appDelegate().dataManager
    }()

    private var statusBarHeight: CGFloat {
        return UIApplication.sharedApplication().statusBarFrame.height
    }
    
    private var searchBarHeight: CGFloat {
       return 44
    }
    
    private var searchBarMargin: CGFloat {
        return 8
    }
    
    private var navbarHeight: CGFloat  {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }
    
    // search bar height + 8 points margin
    private var topOffset: CGFloat {
        return self.searchBarHeight + searchBarMargin
    }
    
    private var initialLayout = true
    
    /**
     * CollectionView content offset is determined by status bar and navigation bar height
     */
    private var topItemOffset: CGFloat {
        return -(self.statusBarHeight + self.navbarHeight)
    }
    
    func shouldStrech() -> Bool {
        return !searchController.active
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let decksLayout = collectionView?.collectionViewLayout as? DecksCollectionViewLayout {
            decksLayout.delegate = self 
        }
        searchBarWrapper = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: searchBarHeight))
        searchBarWrapper.autoresizingMask = .FlexibleWidth
        searchBarWrapper.addSubview(searchBar)
        view.addSubview(searchBarWrapper)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        collectionView?.backgroundColor = UIColor.sb_White()
        collectionView?.alwaysBounceVertical = true
    }
   
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.sizeToFit()
        if let drawer = UIApplication.sharedRootViewController as? SBDrawerController {
            drawer.addObserver(self, forKeyPath: "openSide", options: [.New, .Old], context: nil)
        }
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(orientationChanged(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        dataManager.userDecks {
            switch $0 {
            case .Success(let obj):
                self.decksArray = obj
            case .Error(_):
                self.presentAlertController(withTitle: "Błąd", message: "Błąd pobierania danych", buttonText: "Ok")
            }
            self.collectionView?.reloadData()
        }
        if initialLayout {
            adjustCollectionLayout(forSize: view.bounds.size)
            initialOffset(false)
        }
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.view.removeFromSuperview()
        if let drawer = UIApplication.sharedRootViewController as? SBDrawerController {
            drawer.removeObserver(self, forKeyPath: "openSide")
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
        initialLayout = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchController.searchBar.sizeToFit()
        if initialLayout {
            initialOffset(false)
            initialLayout = !initialLayout
            
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        adjustCollectionLayout(forSize: size)
        
    }
    func orientationChanged(notification: NSNotification) {
        initialLayout = true
    }
   
    func initialOffset(animated: Bool) {
        collectionView?.setContentOffset(CGPoint(x: 0, y: topItemOffset + searchBarHeight), animated: animated)
    }
    
    func adjustCollectionLayout(forSize size: CGSize) {
        let layout = collectionView?.collectionViewLayout
        if let flow = layout as? UICollectionViewFlowLayout {
            let spacing = Utils.DeckViewLayout.DecksSpacing
            equalSizeAndSpacing(forScreenSize: size, cellSquareSide: Utils.DeckViewLayout.CellSquareSize, spacing: spacing, collectionFlowLayout: flow)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "openSide", let newSide = change?["new"] as? Int, let oldSide = change?["old"] as? Int where newSide != oldSide {
            initialOffset(true)
        }
    }
    
    class func numberOfCellsInRow(screenWidth: CGFloat, cellSize: CGFloat) -> CGFloat {
        return floor(screenWidth / cellSize)
    }
    
    // this function calculate size of decks, by given spacing and size of cells
    private func equalSizeAndSpacing(forScreenSize screenSize: CGSize, cellSquareSide cellSize: CGFloat, spacing: CGFloat,
                                                        collectionFlowLayout flow: UICollectionViewFlowLayout){
            
        let crNumber = DecksViewController.numberOfCellsInRow(screenSize.width, cellSize: cellSize)
        
        let deckWidth = screenSize.width / crNumber - (spacing + spacing/crNumber)
        flow.sectionInset = UIEdgeInsetsMake(topOffset, spacing, spacing, spacing)
        // spacing between decks
        flow.minimumInteritemSpacing = spacing
        // spacing between rows
        flow.minimumLineSpacing = spacing
        // size for every deck
        flow.itemSize = CGSize(width: deckWidth, height: deckWidth)
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return 1
    }

    // Calculate number of decks. If no decks, return 0
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let searchDecksCount = searchDecks?.count {
            return searchDecksCount
        } else if let decksCount = decksArray?.count {
            return  decksCount
        }
        return 0
    }
    
    // Populate cells with decks data. Change cells style
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let source = searchDecks ?? decksArray
        
        let view = collectionView.dequeueReusableCellWithReuseIdentifier(Utils.UIIds.DecksViewCellID, forIndexPath: indexPath)
        if let cell = view as? DecksViewCell{
            cell.layoutIfNeeded()
            
            if var deckName = source?[indexPath.row].name {
                if deckName.isEmpty {
                    deckName = Utils.DeckViewLayout.DeckWithoutTitle
                }
                cell.deckNameLabel.text = deckName
            }
            // changing label UI
            if let font = UIFont.sbFont(size: sbFontSizeLarge, bold: false) {
                cell.deckNameLabel.adjustFontSizeToHeight(font, max: sbFontSizeLarge, min: sbFontSizeSmall)
            }
            cell.deckNameLabel.textColor = UIColor.whiteColor()
            cell.deckNameLabel.numberOfLines = 0
            // adding line breaks
            cell.deckNameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.deckNameLabel.preferredMaxLayoutWidth = cell.bounds.size.width
            cell.contentView.backgroundColor = UIColor.sb_Graphite()
            return cell
        }
        return view
    }
    
    // When cell tapped, change to test
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let source = searchDecks ?? decksArray
        
        if let deck = source?[indexPath.row] {
            let resetSearchUI = {
                self.searchController.active = false
            }
            
            dataManager.flashcards(deck.serverID) {
                switch $0 {
                case .Success(let flashcards):
                    guard !flashcards.isEmpty else {
                        self.presentAlertController(withTitle: "Błąd", message: "Talia nie ma fiszek", buttonText: "Ok")
                        return
                    }
                    let alert = UIAlertController(title: "Test czy nauka?", message: "Wybierz tryb, który chcesz uruchomić", preferredStyle: .Alert)
                    
                    let testButton = UIAlertAction(title: "Test", style: .Default){ (alert: UIAlertAction!) -> Void in
                        let alertAmount = UIAlertController(title: "Jaka ilość fiszek?", message: "Wybierz ilość fiszek w teście", preferredStyle: .Alert)
                        
                        let amounts = [ 1, 5, 10, 15, 20 ]
                        
                        var amountFlashcardsNotHiden: Int = 0
                        for flashcard in flashcards {
                            if flashcard.hidden == false {
                                amountFlashcardsNotHiden += 1
                            }
                        }
                        
                        for amount in amounts {
                            if amount < amountFlashcardsNotHiden {
                                alertAmount.addAction(UIAlertAction(title: String(amount), style: .Default) { act in
                                    resetSearchUI()
                                    self.performSegueWithIdentifier("StartTest",
                                        sender: Test(deck: flashcards, deckName: deck.name, testType: .Test(UInt32(amount))))
                                    })
                            } else {
                                break
                            }
                        }
                        alertAmount.addAction(UIAlertAction(title: "Wszystkie (" + String(amountFlashcardsNotHiden) + ")", style: .Default) { act in
                            resetSearchUI()
                            self.performSegueWithIdentifier("StartTest",
                                sender: Test(deck: flashcards, deckName: deck.name, testType: .Test(UInt32(amountFlashcardsNotHiden))))
                            })
                        alertAmount.addAction(UIAlertAction(title: "Anuluj", style: UIAlertActionStyle.Cancel, handler: nil))
                        
                        self.presentViewController(alertAmount, animated: true, completion:nil)
                    }
                    let studyButton = UIAlertAction(title: "Nauka", style: .Default) { (alert: UIAlertAction!) -> Void in
                        resetSearchUI()
                        self.performSegueWithIdentifier("StartTest", sender: Test(deck: flashcards, deckName: deck.name, testType: .Learn))
                    }
                    
                    alert.addAction(testButton)
                    alert.addAction(studyButton)
                    alert.addAction(UIAlertAction(title: "Anuluj", style: UIAlertActionStyle.Cancel, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion:nil)
                    
                case .Error(_):
                    self.presentAlertController(withTitle: "Błąd", message: "Nie udało się pobrać danych", buttonText: "Ok")
                }
                
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StartTest", let testViewController = segue.destinationViewController as? TestViewController, let testLogic = sender as? Test {
            testViewController.testLogicSource = testLogic
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
}

extension DecksViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    
    func adjustSearchBar(forYOffset offset: CGFloat) {
        if !searchController.active {
            if offset < topItemOffset + topOffset {
                
                if offset > topItemOffset{
                    searchBarWrapper.frame.origin.y = -offset
                } else {
                    searchBarWrapper.frame.origin.y = -topItemOffset
                }
                
            } else {
                searchBarWrapper.frame.origin.y = -searchBarHeight
            }
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        adjustSearchBar(forYOffset: offset)
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text where !searchText.characters.isEmpty {
            let searchLowercase = searchText.lowercaseString
            let deckWithoutTitleLowercase = Utils.DeckViewLayout.DeckWithoutTitle.lowercaseString
            searchDecks = decksArray?
                .filter {
                    return $0.name.lowercaseString.containsString(searchLowercase)
                        || ( $0.name == "" && deckWithoutTitleLowercase.containsString(searchLowercase) )
                }
                .sort { a, b in
                    return a.name < b.name
                }
            
        } else {
            searchDecks = nil
        }
        collectionView?.reloadData()
        

    }
    func willPresentSearchController(searchController: UISearchController) {
        if collectionView?.contentOffset.y > topItemOffset {
            collectionView?.contentOffset.y = topItemOffset
        }
    }
   
    func didDismissSearchController(searchController: UISearchController) {
        searchController.searchBar.sizeToFit()
    }
}

// this extension dynamically change the size of the fonts, so text can fit
extension UILabel {
    func adjustFontSizeToHeight(font: UIFont, max: CGFloat, min: CGFloat)
    {
        var font = font
        // Initial size is max and the condition the min.
        for size in max.stride(through: min, by: -0.1) {
            font = font.fontWithSize(size)
            if let text = self.text{
                let attrString = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
                let rectSize = attrString.boundingRectWithSize(CGSize(width: self.bounds.width, height: CGFloat.max),
                                                               options: .UsesLineFragmentOrigin, context: nil)
                
                if rectSize.size.height <= self.bounds.height
                {
                    self.font = font
                    break
                }
            }
        }
        // in case, it is better to have the smallest possible font
        self.font = font
    }
}
