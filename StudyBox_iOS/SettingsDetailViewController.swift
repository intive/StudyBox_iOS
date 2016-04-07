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
    let switchCellID = "switchCell"
    
    var mode:settingsDetailVCType!
    lazy private var dataManager:DataManager? = { return UIApplication.appDelegate().dataManager }()
    ///Array that holds all user's decks
    var userDecksArray: [Deck]?
    ///Array that holds
    var decksToSynchronize: [(Deck,Bool)]?
    //var notificationsEnabled:Bool
    
    
    @IBOutlet weak var detailTableView: UITableView!
    
    override func viewDidLoad() {
        
        if let mode = self.mode {
            switch mode {
            case .DecksForWatch:
                self.title = "Wybór talii"
                copyUserDecksToSync()
            case .Frequency:
                self.title = "Powiadomienia"
                    //check defaults, if not found then create notifications = false
            }
        }
        
        
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell!
        
        if let mode = self.mode {
            switch mode {
            case .Frequency:
                switch (indexPath.section, indexPath.row){
                case (0,0): cell = tableView.dequeueReusableCellWithIdentifier(switchCellID, forIndexPath: indexPath)
                    let mySwitch = UISwitch(frame: CGRectZero) as UISwitch
                    mySwitch.on = true //set from defaults
                    cell.accessoryView = mySwitch
                case (0,1): cell = tableView.dequeueReusableCellWithIdentifier(pickerCellID, forIndexPath: indexPath)
                default: break
                }
                cell.textLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
                
            case .DecksForWatch:
                cell = tableView.dequeueReusableCellWithIdentifier(checkmarkCellID, forIndexPath: indexPath)
                switch indexPath.section {
                case 0:
                    cell.textLabel?.text = "Zaznacz/Odznacz wszystkie"
                case 1:
                    if let deckName = userDecksArray?[indexPath.row].name {
                        cell.textLabel?.text = deckName.isEmpty ? Utils.DeckViewLayout.DeckWithoutTitle : deckName
                    }
                default: break
                }
                cell.textLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
                //TODO: set checkmark based on NSUserDefaults
                
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell: UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
        if indexPath == NSIndexPath(forRow: 0, inSection: 0) {
            //We tap `select/deselect all`
            if let deck = userDecksArray {
                for row in 0..<deck.count {
                    if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 1))
                    {
                        if cell.accessoryType == .None {
                            cell.accessoryType = .Checkmark
                            //TODO add selected deck to NSUserDefaults?
                        } else {
                            cell.accessoryType = .None
                            //TODO remove selected deck from NSUserDefaults?
                        }
                    }
                }
            }
            
        } else {
            //We didn't tap the `select/deselect all` row
            if let selectedCell = cell, let mode = self.mode where mode == .DecksForWatch {
                //let selectedRow = indexPath.row
                if selectedCell.accessoryType == .None {
                    selectedCell.accessoryType = .Checkmark
                    
                    //userDecksArray?[selectedRow].id
                    //TODO add selected deck to NSUserDefaults?
                } else {
                    selectedCell.accessoryType = .None
                    //TODO remove selected deck from NSUserDefaults?
                }
            }
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func copyUserDecksToSync() {
        userDecksArray = dataManager?.decks(true)
        
        //TODO: Do this loop only if it's the first time the user chooses decks, set a flag in NSUserDefaults
        //        if let userDecksArray = userDecksArray, var decksToSynchronize = decksToSynchronize {
        //            for i in 0...userDecksArray.count {
        //                decksToSynchronize[i] = (userDecksArray[i],false)
        //            }
        //            self.decksToSynchronize! = decksToSynchronize
        //        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        if let mode = self.mode {
            switch mode {
            case .Frequency: rows = 2
            case .DecksForWatch:
                switch section {
                case 0: rows = 1
                case 1:
                    if let deck = userDecksArray {
                        rows = deck.count
                    }
                default: break
                }
            }
        }
        return rows
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height = tableView.rowHeight
        
        if let mode = self.mode {
            switch mode {
            case .Frequency:
                switch (indexPath.section, indexPath.row){
                case (0,0): height = CGFloat(44) //height of switch cell
                case (0,1): height = CGFloat(140) //height of pickerView
                default: break
                }
            case .DecksForWatch: height = CGFloat(44) //height of checkmarkCell
            }
        }
        return height
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var sections = 0
        if let mode = self.mode {
            switch mode {
            case .Frequency: sections = 1
            case .DecksForWatch: sections = 2
            }
        }
        return sections
    }
}
