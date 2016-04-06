//
//  SettingsDetailViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 05.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

enum settingsDetailVCType {
    case Frequency
    case DecksForWatch
}

class SettingsDetailViewController: StudyBoxViewController, UITableViewDataSource, UITableViewDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let pickerCellID = "pickerCell"
    let checkmarkCellID = "checkmarkCell"
    var mode:settingsDetailVCType?
    lazy private var dataManager:DataManager? = { return UIApplication.appDelegate().dataManager }()
    var decksArray: [Deck]?

    @IBOutlet weak var detailTableView: UITableView!

    override func viewDidLoad() {
        //for test purposes
        mode = .Frequency
        
        if let aMode = self.mode {
            switch aMode {
            case .DecksForWatch:
                self.title = "Wybór talii"
                decksArray = dataManager?.decks(true)
            case .Frequency:
                self.title = "Powiadomienia"
            }
        }
        
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell?
        
        if let mode = self.mode {
            switch mode {
            case .Frequency:
                cell = tableView.dequeueReusableCellWithIdentifier(pickerCellID, forIndexPath: indexPath)
                cell?.textLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
            case .DecksForWatch:
                cell = tableView.dequeueReusableCellWithIdentifier(checkmarkCellID, forIndexPath: indexPath)
                if var deckName = decksArray?[indexPath.row].name {
                    if deckName.isEmpty {
                        deckName = Utils.DeckViewLayout.DeckWithoutTitle
                    }
                    cell?.textLabel?.text = deckName
                }
                cell?.textLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
            }
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell: UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
        if let selectedCell = cell {
            if selectedCell.accessoryType == .None {
                selectedCell.accessoryType = .Checkmark
                //TODO add selected deck to NSUserDefaults?
            } else {
                selectedCell.accessoryType = .None
                //TODO remove selected deck from NSUserDefaults?
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows:Int?
        
        if let mode = self.mode {
            switch mode {
            case .Frequency: rows = 1
            case .DecksForWatch:
                if let deck = decksArray {
                    rows = deck.count
                }
            }
        }
        return rows!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height = tableView.rowHeight
        
        if let mode = self.mode {
            switch mode {
            case .Frequency: height = CGFloat(140)
            case .DecksForWatch: height = CGFloat(44)
            }
        }
        return height
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
