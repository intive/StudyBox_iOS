//
//  DecksViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz, Damian Malarczyk on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//
import UIKit
import SVProgressHUD

class DecksViewController: StudyBoxCollectionViewController, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout, DecksCollectionLayoutDelegate {
    
    var searchBarWrapper: UIView!
    var searchBarTopConstraint: NSLayoutConstraint!
    var searchController: UISearchController = UISearchController(searchResultsController: nil)
    let refreshControl = UIRefreshControl()

    var searchBar: UISearchBar {
        return searchController.searchBar
    }
    var currentSortingOption: DecksSortingOption = .Name
    
    var decksArray: [(Deck, Int)] = []
    var searchDecks: [(Deck, Int)] = []
    var searchDecksHolder: [(Deck, Int)] = []
    var searchDelay: NSTimer?
    var emptySearch: Bool = true
    
    var decksSource: [(Deck, Int)] {
        return searchDecks.isEmpty && !searchController.active ? decksArray : searchDecks
    }
    
    
    lazy var dataManager: DataManager = UIApplication.appDelegate().dataManager

    private var statusBarHeight: CGFloat {
        return UIApplication.sharedApplication().statusBarFrame.height
    }
    
    var searchBarHeight: CGFloat {
       return 44
    }
    
    private var searchBarMargin: CGFloat {
        return 8
    }
    
    private var navbarHeight: CGFloat  {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }
    
    // search bar height + 8 points margin
    var topOffset: CGFloat {
        return self.searchBarHeight + searchBarMargin
    }
    
    private var initialLayout = true
    
    /**
     * CollectionView content offset is determined by status bar and navigation bar height
     */
    var topItemOffset: CGFloat {
        return -(self.statusBarHeight + self.navbarHeight)
    }
    
    func shouldStrech() -> Bool {
        return !searchController.active
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.collectionViewLayout = DecksCollectionViewLayout()
        collectionView?.collectionViewLayout.invalidateLayout()
        if let decksLayout = collectionView?.collectionViewLayout as? DecksCollectionViewLayout {
            decksLayout.delegate = self 
        }
        navigationItem.title = "Moje talie"
        searchBarWrapper = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: searchBarHeight))
        searchBarWrapper.autoresizingMask = .FlexibleWidth
        searchBarWrapper.addSubview(searchBar)
        view.addSubview(searchBarWrapper)
        searchBar.delegate = self
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        collectionView?.backgroundColor = UIColor.sb_White()
        collectionView?.alwaysBounceVertical = true
        refreshControl.tintColor = UIColor.sb_Graphite()
        refreshControl.addTarget(self, action: #selector(reloadData), forControlEvents: .ValueChanged)
        reloadData()
    }
    
    func reloadData() {
        let reloadBlock = { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.collectionView?.reloadData()
        }
        
        let completion:(userDecks: Bool) -> (DataManagerResponse<[(Deck, Int)]> -> ()) = { userDecks in
            return {
                switch $0 {
                case .Success(let obj):
                    if userDecks {
                        self.decksArray = obj
                    } else {
                        let schuffled = obj.shuffle()
                        self.decksArray = Array(schuffled.prefix(3))

                    }
                case .Error(let err):
                    self.decksArray = []
                    debugPrint(err)
                    SVProgressHUD.showErrorWithStatus("Błąd pobierania danych")
                }
                reloadBlock()
            }
        }
        
        if UIApplication.isUserLoggedIn  {
            dataManager.userDecksWithFlashcardsCount(completion(userDecks: true))
            
        } else {
            if let collectionView = collectionView {
                if DecksViewController.numberOfCellsInRow(collectionView.frame.width, cellSize: Utils.DeckViewLayout.CellSquareSize) < 2 {
                    decksArray = []
                    reloadBlock()
                }
            }
            
            dataManager.decksWithFlashcardsCount(completion: completion(userDecks: false))
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.sizeToFit()
        self.collectionView?.addSubview(refreshControl)
        if let drawer = UIApplication.sharedRootViewController as? SBDrawerController {
            drawer.addObserver(self, forKeyPath: "openSide", options: [.New, .Old], context: nil)
        }
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: #selector(orientationChanged(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
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
        let cellCount = DecksViewController.numberOfCellsInRow(size.width, cellSize: Utils.DeckViewLayout.CellSquareSize)
        let cellSquareSize = (size.width - ((cellCount + 1) * Utils.DeckViewLayout.DecksSpacing)) / cellCount
        let cellSize = CGSize(width: cellSquareSize, height: cellSquareSize)
        if let visibleCells = collectionView?.visibleCells() as? [DecksViewCell] {
            
            for cell in visibleCells {
                cell.reloadBorderLayer(forCellSize: cellSize)
            }
        }
        
    }
    
    func orientationChanged(notification: NSNotification) {
        if traitCollection.horizontalSizeClass != .Compact {
            initialLayout = true
        }
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
        if keyPath == "openSide", let newSide = change?["new"] as? Int, oldSide = change?["old"] as? Int where newSide != oldSide {
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
        
        flow.sectionInset = UIEdgeInsets(top: topOffset, left: spacing, bottom: spacing, right: spacing)
        // spacing between decks
        flow.minimumInteritemSpacing = spacing
        // spacing between rows
        flow.minimumLineSpacing = spacing
        // size for every deck
        flow.itemSize = CGSize(width: deckWidth, height: deckWidth)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StartTest", let testViewController = segue.destinationViewController as? TestViewController, testLogic = sender as? Test {
            testViewController.testLogicSource = testLogic
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func sortButtonPress(sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Typ filtrowania", message: "Aktualnie:\n\(currentSortingOption.description)", preferredStyle: .ActionSheet)
        let availableFilters: [DecksSortingOption] = [.CreateDate, .FlashcardsCount(ascending: true), .FlashcardsCount(ascending: false), .Name]
        availableFilters.forEach { option in
            alert.addAction(UIAlertAction(title: option.description, style: .Default) { _ in
                self.changeSortingOption(option)
                })
            
        }
        alert.addAction(UIAlertAction(title: "Anuluj", style: .Cancel, handler: nil))
        alert.popoverPresentationController?.barButtonItem = sender
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func changeSortingOption(option: DecksSortingOption) {
        currentSortingOption = option
        decksArray = currentSortingOption.sort(decksArray)
        searchDecks = currentSortingOption.sort(searchDecks)
        collectionView?.reloadData()
    }
    
}
