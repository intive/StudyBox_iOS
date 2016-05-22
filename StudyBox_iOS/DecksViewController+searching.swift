//
//  DecksViewController+searching.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 18.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import Reachability

extension DecksViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    func adjustSearchBar(forYOffset offset: CGFloat) {
        if !searchController.active {
            if offset < topItemOffset + topOffset {
                
                searchBarWrapper.frame.origin.y = -offset
                
            } else {
                searchBarWrapper.frame.origin.y = -searchBarHeight
            }
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        adjustSearchBar(forYOffset: offset)
        
    }
    
    func filterOnlineDecks(timer: NSTimer) {
        
        guard Reachability.isConnected() else {
            presentAlertController(withTitle: "Błąd", message: "Brak połączenia z internetem", buttonText: "Ok")
            return
        }
        guard let filter = timer.userInfo?["searchText"] as? String else {
            return
        }
        
        let searchText = filter.trimWhiteCharacters()
        if !searchText.characters.isEmpty && searchText.characters.count <= 100 {
            let searchBlock = {
                self.searchDecks = self.searchDecksHolder
                    .filter {
                        return $0.matches(searchText)
                    }.sort {
                        if let lDate = $0.0.createDate {
                            if let rdate = $0.1.createDate {
                                return lDate.timeIntervalSinceDate(rdate) > 0
                            }
                            return true
                        }
                        return false
                }
                self.collectionView?.reloadData()
                
            }
            if searchDecksHolder.isEmpty {
                dataManager.decks(true) {
                    switch $0 {
                    case .Success(let obj):
                        self.searchDecksHolder = obj
                        searchBlock()
                        
                    case .Error:
                        self.presentAlertController(withTitle: "Błąd", message: "Pobranie danych nie było możliwe, spróbuj później", buttonText: "Ok")
                    }
                }
            } else {
                searchBlock()
            }
        } else {
            searchDecks = []
            collectionView?.reloadData()
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchDelay = searchDelay {
            searchDelay.invalidate()
        }
        searchDelay = NSTimer(timeInterval: 0.05, target: self,
                              selector: #selector(filterOnlineDecks(_:)), userInfo: ["searchText": searchText], repeats: false)
        searchDelay?.fire()
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        if collectionView?.contentOffset.y > topItemOffset {
            collectionView?.contentOffset.y = topItemOffset
        }
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        searchDecks = []
        collectionView?.reloadData()
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        searchController.searchBar.sizeToFit()
        searchDecksHolder = []
    }
}
