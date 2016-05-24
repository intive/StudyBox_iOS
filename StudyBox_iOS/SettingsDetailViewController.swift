//
//  SettingsDetailViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 05.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import WatchConnectivity
import SVProgressHUD

enum SettingsDetailVCMode {
    case Frequency
    case DecksForWatch
}

protocol SettingsDetailVCChangeDecksDelegate {
    func updateDecks()
}

class SettingsDetailViewController: StudyBoxViewController, UITableViewDataSource, UITableViewDelegate, WCSessionDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let pickerCellID = "pickerCell"
    let checkmarkCellID = "checkmarkCell"
    let switchCellID = "switchCell"
    var mode: SettingsDetailVCMode!
    var delegate: SettingsDetailVCChangeDecksDelegate?
    lazy private var dataManager: DataManager = { return UIApplication.appDelegate().dataManager }()
    
    ///Array that holds all user's local decks
    var userDecksArray: [Deck]?
    
    var fireDate = NSDate()
    @IBOutlet weak var detailTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch mode {
        case .DecksForWatch?:
            self.title = "Wybór talii"
            if let email = dataManager.remoteDataManager.user?.email {
                userDecksArray = dataManager.localDataManager.filter(Deck.self, predicate: "owner = '\(email)'")
            }
        case .Frequency?:
            self.title = "Powiadomienia"
        default:
            break
        }
        
        detailTableView.backgroundColor = UIColor.sb_Grey()
        WatchDataManager.watchManager.startSession()
    }
    
    //Handle tapping the Back button
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        switch mode {
        case .Frequency?:
            if defaults.boolForKey(Utils.NSUserDefaultsKeys.NotificationsEnabledKey) {
                UIApplication.appDelegate().scheduleNotification()
            }
        case .DecksForWatch?:
            saveSelectedDecksToUserDefaults()
            if let delegate = delegate {
                delegate.updateDecks()
            }
        default:
            break
        }
        defaults.synchronize()
    }
    
//MARK: TableView methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        
        switch mode {
        case .Frequency?:
            switch (indexPath.section, indexPath.row){
            case (0, 0): cell = tableView.dequeueReusableCellWithIdentifier(switchCellID, forIndexPath: indexPath)
            case (0, 1): cell = tableView.dequeueReusableCellWithIdentifier(pickerCellID, forIndexPath: indexPath)
            default: break
            }
        case .DecksForWatch?:
            cell = tableView.dequeueReusableCellWithIdentifier(checkmarkCellID, forIndexPath: indexPath)
            configureDecksForWatchCell(cell, atIndexPath: indexPath)
        default: break
        }
        cell.textLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        cell.backgroundColor = UIColor.sb_White()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell: UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
        var selectAllState: UITableViewCellAccessoryType = .None
        if mode == .DecksForWatch {
            if indexPath == NSIndexPath(forRow: 0, inSection: 0) {
                //We tap `select/deselect all`
                if let selectAllCell = tableView.cellForRowAtIndexPath(indexPath) {
                    changeSelectionForCell(selectAllCell)
                    selectAllState = selectAllCell.accessoryType
                }
                
                //Change selection of all cells in section 1 based on "Select all" cell
                if let deck = userDecksArray {
                    for row in 0..<deck.count {
                        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 1))
                        {
                            changeSelectionForCell(cell, toState: selectAllState)
                        }
                    }
                }
                
            } else {
                //We didn't tap the `select/deselect all` row, so change only selected row and deselect `select/deselect all` row
                if let selectedCell = cell {
                    changeSelectionForCell(selectedCell)
                }
                if let selectAllCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)){
                    changeSelectionForCell(selectAllCell, toState: .None)
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        switch mode {
        case .Frequency?: rows = 2
        case .DecksForWatch?:
            switch section {
            case 0: rows = 1
            case 1:
                if let deck = userDecksArray {
                    rows = deck.count
                }
            default: break
            }
        default:
            break
        }
        return rows
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = tableView.rowHeight
        
        if let mode = self.mode where mode == .Frequency{
            if indexPath.section == 0 && indexPath.row == 1 {
                height = CGFloat(140) //height of pickerView
            }
        }
        return height
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch mode {
        case .Frequency?: return 1
        case .DecksForWatch?: return 2
        default: return 0
        }
    }
    
    private func configureDecksForWatchCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        guard let userDecksArray = userDecksArray else {
            return
        }
        
        let decksToSynchronize: [String]
        if let decksToSync = defaults.objectForKey(Utils.NSUserDefaultsKeys.DecksToSynchronizeKey) as? [String] {
            decksToSynchronize = decksToSync
        } else {
            decksToSynchronize = []
        }
        
        switch indexPath.section {
        case 0:
            //Check the "Select/deselect all" cell if all decks are already set to sync
            if decksToSynchronize.count == userDecksArray.count {
                cell.accessoryType = .Checkmark
            }
            
            cell.textLabel?.text = "Zaznacz/Odznacz wszystkie"
        case 1:
            let deckName = userDecksArray[indexPath.row].name
            cell.textLabel?.text = deckName.isEmpty ? Utils.DeckViewLayout.DeckWithoutTitle : deckName
            cell.accessoryType = .None
            
            //Enable the checkmark if `decksToSynchronize` contains current Deck in cell
            for deckToSync in decksToSynchronize where !decksToSynchronize.isEmpty {
                if deckToSync == userDecksArray[indexPath.row].serverID {
                    cell.accessoryType = .Checkmark
                }
            }
            
        default: break
        }
    }

    //Inverses cell checkmark on/off
    func changeSelectionForCell(cell: UITableViewCell) {
        if cell.accessoryType == .None {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
    }
    
    //Sets cell checkmark to `toState`
    func changeSelectionForCell(cell: UITableViewCell, toState: UITableViewCellAccessoryType) {
        cell.accessoryType = toState
    }

    ///Sends decks selected in TableView to NSUD and Watch
    func saveSelectedDecksToUserDefaults() {
        let decksToSynchronizeIDs = convertSelectedDecksToIDs()
        defaults.setObject(decksToSynchronizeIDs, forKey: Utils.NSUserDefaultsKeys.DecksToSynchronizeKey)
    }
    
    //Converts decks selected in `detailTableView` to array of their IDs
    func convertSelectedDecksToIDs() -> [String] {
        var decksToSynchronize = [String]()
        if let userDecksArray = userDecksArray {
            for i in 0..<userDecksArray.count {
                let cell = detailTableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 1))
                if cell?.accessoryType == .Checkmark {
                    decksToSynchronize.append(userDecksArray[i].serverID)
                }
            }
        }
        return decksToSynchronize
    }

}
