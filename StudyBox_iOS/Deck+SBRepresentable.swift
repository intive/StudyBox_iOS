//
//  Deck+uiName.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 15.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension Deck: SBRepresentable {
    
    func uiName() -> String {
        switch name {
        case "":
           return Utils.DeckViewLayout.DeckWithoutTitle
        default:
            return name
            
        }
    }
}