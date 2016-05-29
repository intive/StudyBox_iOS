//
//  DecksFilter.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 27.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

enum DecksSortingOption: CustomStringConvertible {
    case CreateDate, FlashcardsCount(ascending: Bool), Name
    
    var description: String {
        switch self {
        case .CreateDate:
            return "Data utworzenia"
        case .FlashcardsCount(let ascending):
            return "Ilość fiszek " + (ascending ? "rosnąco" : "malejąco")
        case .Name:
            return "Alfabetycznie"
        }
    }
    
    func sort(decks: [(Deck, Int)]) -> [(Deck, Int)] {
        switch self {
        case .CreateDate:
            return decks.sort {
                if let lDate = $0.0.createDate {
                    if let rdate = $1.0.createDate {
                        return lDate.timeIntervalSinceDate(rdate) > 0
                    }
                    return true
                }
                return false
            }
        case .FlashcardsCount(let asc):
        
            if asc {
                return decks.sort {
                    return $0.1 < $1.1
                }
            } else {
                return decks.sort {
                    return $0.1 > $1.1
                }
            }
        case .Name:
            return  decks.sort {
                return $0.0.name.localizedCompare($1.0.name) == NSComparisonResult.OrderedAscending
            }
        }
    }
}
