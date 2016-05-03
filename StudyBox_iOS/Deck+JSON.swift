//
//  Deck+JSON.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import SwiftyJSON

extension Deck {
    class func withJSON(json: JSON) -> Deck? {
        if let jsonDict = json.dictionary {
            if let id = jsonDict["id"]?.string, name = jsonDict["name"]?.string {
                return Deck(serverID: id, name: name)
            }
        }
        return nil
    }
    
    class func arrayWithJSON(json: JSON) -> [Deck] {
        var decks = [Deck]()
        if let jsonArray = json.array {
            jsonArray.forEach {
                if let deck = Deck.withJSON($0) {
                    decks.append(deck)
                }
            }
        }
        return decks
    }
}