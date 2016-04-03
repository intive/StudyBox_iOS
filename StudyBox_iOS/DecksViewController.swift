//
//  DecksViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class DecksViewController: StudyBoxViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    private var decksArray: [Deck]?
    private var searchDecks: [Deck]?
    
    lazy private var dataManager:DataManager? = {
        return UIApplication.appDelegate().dataManager
    }()
    
    @IBOutlet var decksCollectionView: UICollectionView!
    
    private var searchBar: UISearchBar?

    var isSearchBarVisible = false
    var isSearching = false

    lazy private var statusBarHeight: CGFloat = {
        return UIApplication.sharedApplication().statusBarFrame.height
    }()
    
    lazy private var navbarHeight: CGFloat = {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }()
    
    /**
     * CollectionView content offset is determined by status bar and navigation bar height
     */
    lazy private var topItemOffset: CGFloat = {
        return -(self.statusBarHeight + self.navbarHeight)
    }()

    private var searchBarHeight: CGFloat = 44
    private var marginValue: CGFloat = 8

    private var softAnimationDuration = 0.2
    private var accurateAnimationDuration = 0.5

    // TODO: in future replace managerWithDummyData()
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let drawer = UIApplication.sharedRootViewController as? SBDrawerController {
            drawer.addObserver(self, forKeyPath: "openSide", options: [.New,.Old], context: nil)
            
        }
        decksArray = dataManager?.decks(true)
        searchBar?.delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar?.delegate = nil
        if let drawer = UIApplication.sharedRootViewController as? SBDrawerController {
            drawer.removeObserver(self, forKeyPath: "openSide")
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        
        decksCollectionView.delegate = self
        decksCollectionView.dataSource = self
        let layout = decksCollectionView.collectionViewLayout
        let flow = layout as! UICollectionViewFlowLayout
        let spacing = Utils.DeckViewLayout.DecksSpacing
        equalSizeAndSpacing(numberOfCellsInRow: Utils.DeckViewLayout.DecksInRowIPhoneVer, spacing: spacing, collectionFlowLayout: flow)

        decksCollectionView.backgroundColor = UIColor.whiteColor()
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(DecksViewController.hideKeyboard))
        swipeGestureRecognizer.direction = [.Down,.Up]
        decksCollectionView.addGestureRecognizer(swipeGestureRecognizer)
        swipeGestureRecognizer.delegate = self
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "openSide",let newSide = change?["new"] as? Int, let oldSide = change?["old"] as? Int where newSide != oldSide {
            
            if newSide != 0 {
                hideSearchBar(navbarHeight)

            }else {
                hideSearchBar(-topItemOffset)
            }

        }
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
        if let searchDecksCount = searchDecks?.count {
            cellsNumber = searchDecksCount
        } else if let decksCount = decksArray?.count {
            cellsNumber = decksCount
        }
        return cellsNumber
    }

    // Populate cells with decks data. Change cells style
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let source = searchDecks ?? decksArray

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Utils.UIIds.DecksViewCellID, forIndexPath: indexPath)
        as! DecksViewCell

        cell.layoutIfNeeded()
        
        if var deckName = source?[indexPath.row].name {
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
        
        let source = searchDecks ?? decksArray
        if let deck = source?[indexPath.row] {
            
            do {
                
                if let flashcards = try dataManager?.flashcards(forDeckWithId: deck.id) {

					if let bar = searchBar {
                        searchDecks = nil
                        hideSearchBar(-topItemOffset)
                        self.cancelSearchReposition(bar, animated: true)
        			}
                   
                    let alert = UIAlertController(title: "Test or Learn?", message: "Choose the mode which you would like to start", preferredStyle: .Alert)
                    
                    let testButton = UIAlertAction(title: "Test", style: .Default){ (alert: UIAlertAction!) -> Void in
                        let alertAmount = UIAlertController(title: "How many flashcards?", message: "Choose amount of flashcards in the test", preferredStyle: .Alert)
                        
                        func handler(act:UIAlertAction) {
                            if((act.title) != nil)
                            {
                                var amount:UInt32
                                switch act.title! {
                                case "1":
                                    amount = 1
                                case "5":
                                    amount = 5
                                case "10":
                                    amount = 10
                                case "15":
                                    amount = 15
                                case "20":
                                    amount = 20
                                default:
                                    amount = 20
                                }
                                self.performSegueWithIdentifier("StartTest", sender: Test(deck: flashcards, testType: .Test(amount)))
                            }
                        }
                        
                        alertAmount.addAction(UIAlertAction(title: "1", style: .Default, handler: handler))
                        alertAmount.addAction(UIAlertAction(title: "5", style: .Default, handler: handler))
                        alertAmount.addAction(UIAlertAction(title: "10", style: .Default, handler: handler))
                        alertAmount.addAction(UIAlertAction(title: "15", style: .Default, handler: handler))
                        alertAmount.addAction(UIAlertAction(title: "20", style: .Default, handler: handler))
                        
                        self.presentViewController(alertAmount, animated: true, completion:nil)

                    }
                    
                    let studyButton = UIAlertAction(title: "Learn", style: .Default) { (alert: UIAlertAction!) -> Void in
                        self.performSegueWithIdentifier("StartTest", sender: Test(deck: flashcards, testType: .Learn))
                    }
                    
                    alert.addAction(testButton)
                    alert.addAction(studyButton)

                    presentViewController(alert, animated: true, completion:nil)
                    
                }
            } catch let e {
                debugPrint(e)
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StartTest", let testViewController = segue.destinationViewController as? TestViewController, let testLogic = sender as? Test {
            testViewController.testLogicSource = testLogic
        }
    }
    
}

// MARK: UISearchBar implementaton
extension DecksViewController: UISearchBarDelegate {

    func setupSearchBar() {

        let bar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: searchBarHeight))
        bar.searchBarStyle = .Default
        bar.tintColor = UIColor.whiteColor()
        bar.placeholder = "Talie"
        bar.delegate = self
        view.insertSubview(bar, aboveSubview: decksCollectionView)
        searchBar = bar
        
    }
   
    func cancelSearchReposition(searchBar: UISearchBar, animated: Bool) {
        if (isSearching) {
            searchBar.text = nil
            searchBar.setShowsCancelButton(false, animated: animated)
            
            UIView.animateWithDuration(animated ? accurateAnimationDuration : 0,
                animations: {
                    if let navigationBar = self.navigationController?.navigationBar where navigationBar.frame.origin.y < 0 {
                        navigationBar.frame.origin.y = self.statusBarHeight
                    }
                    
                    let top = self.topItemOffset - self.searchBarHeight
                    
                    self.decksCollectionView.contentInset = UIEdgeInsets(top: -top, left: 0, bottom: 0, right: 0)
                    self.decksCollectionView.contentOffset.y = top
                    searchBar.frame = CGRect(x: 0, y: self.navbarHeight + self.statusBarHeight, width: searchBar.frame.width, height: self.searchBarHeight)
                }, completion: { _ in
                    if let rootVC = UIApplication.sharedRootViewController as? SBDrawerController {
                        rootVC.openDrawerGestureModeMask = .Custom
                    }
                    self.searchDecks = nil
                    self.decksCollectionView.reloadData()
                    self.isSearching = false
                }
            )
        }
        
    }

    func startSearchReposition(searchBar: UISearchBar, animated: Bool) {

        if (!isSearching) {
            searchDecks = nil
            
            if let rootVC = UIApplication.sharedRootViewController as? SBDrawerController {
                rootVC.openDrawerGestureModeMask = .None
            }
            
            searchBar.text = nil
            searchBar.setShowsCancelButton(true, animated: animated)
            
            UIView.animateWithDuration(animated ? accurateAnimationDuration : 0,
                animations: {
                    if let navigationBar = self.navigationController?.navigationBar {
                        
                        self.decksCollectionView.contentInset = UIEdgeInsets(top: self.searchBarHeight + self.statusBarHeight + self.marginValue * 2, left: 0, bottom: 0, right: 0)
                        
                        navigationBar.frame.origin.y = -self.navbarHeight
                        
                        searchBar.frame.origin.y = 0
                        searchBar.frame.size.height = self.statusBarHeight + self.searchBarHeight + self.marginValue
                        searchBar.layoutIfNeeded()
                        self.view.layoutIfNeeded()
                        
                    }
                },
                completion: { _ in
                    self.isSearching = true
                    
                }
            )
            
        }
        
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            let searchLowercase = searchText.lowercaseString
            let deckWithoutTitleLowercase = Utils.DeckViewLayout.DeckWithoutTitle.lowercaseString
            searchDecks = decksArray?.filter {
                return $0.name.lowercaseString.containsString(searchLowercase) || ( $0.name == "" && deckWithoutTitleLowercase.containsString(searchLowercase) )
            }.sort { a, b in
                return a.name < b.name
            }
        } else {
            searchDecks = nil
        }

        decksCollectionView.reloadData()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        hideKeyboard()
        cancelSearchReposition(searchBar, animated: true)
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        startSearchReposition(searchBar, animated: true)
    }
    
    func showSearchBar() {
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
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        hideKeyboard()
    }
    
    func hideKeyboard() {
        searchBar?.resignFirstResponder()
    }
    
    func hideSearchBar(top:CGFloat) {
        
        if isSearchBarVisible {
        
            isSearchBarVisible = false
            hideKeyboard()
            

            UIView.animateWithDuration(softAnimationDuration, delay: 0, options: .CurveEaseOut,
                animations: {
                    self.searchBar?.frame.origin.y = 0
                    self.decksCollectionView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)

                },
                completion: nil
            )
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if (!isSearching) {
            if (scrollView.contentOffset.y < topItemOffset) {
                showSearchBar()
                
            }else {
                hideSearchBar(-topItemOffset)
            }
        }
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true 
    }
}

// this extension dynamically change the size of the fonts, so text can fit
extension UILabel {
    func adjustFontSizeToHeight(font: UIFont, max:CGFloat, min:CGFloat)
    {
        var font = font;
        // Initial size is max and the condition the min.
        for size in max.stride(through: min, by: -0.1) {
            font = font.fontWithSize(size)
            let attrString = NSAttributedString(string: self.text!, attributes: [NSFontAttributeName: font])
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
