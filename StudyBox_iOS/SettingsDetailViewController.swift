//
//  SettingsDetailViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 05.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

enum SettingsDetailVCType {
    case Frequency
    case DecksForWatch
}

class SettingsDetailViewController: StudyBoxViewController, UITableViewDataSource, UITableViewDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let pickerCellID = "pickerCell"
    let checkmarkCellID = "checkmarkCell"
    let switchCellID = "switchCell"
    var mode: SettingsDetailVCType!
    lazy private var dataManager: DataManager? = { return UIApplication.appDelegate().dataManager }()
    ///Array that holds all user's decks
    var userDecksArray: [Deck]?
    var fireDate = NSDate()
    @IBOutlet weak var detailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch mode {
        case .DecksForWatch?:
            self.title = "Wybór talii"
            userDecksArray = dataManager?.decks(true)
        case .Frequency?:
            self.title = "Powiadomienia"
        default:
            break
        }
        
        detailTableView.backgroundColor = UIColor.sb_Grey()
    }
    
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
            
            if let userDecksArray = userDecksArray {
                switch indexPath.section {
                case 0:
                    if let decksToSynchronize = defaults.objectForKey(Utils.NSUserDefaultsKeys.DecksToSynchronizeKey) as? [String]{
                        if decksToSynchronize.count == userDecksArray.count {
                            cell.accessoryType = .Checkmark
                        }
                    }
                    cell.textLabel?.text = "Zaznacz/Odznacz wszystkie"
                case 1:
                    let deckName = userDecksArray[indexPath.row].name
                    cell.textLabel?.text = deckName.isEmpty ? Utils.DeckViewLayout.DeckWithoutTitle : deckName
                    
                    cell.accessoryType = .None
                    //Enable the checkmark if `decksToSynchronize` contains current Deck in cell
                    if let decksToSynchronize = defaults.objectForKey(Utils.NSUserDefaultsKeys.DecksToSynchronizeKey) as? [String]{
                        for deckToSync in decksToSynchronize {
                            if deckToSync == userDecksArray[indexPath.row].id {
                                cell.accessoryType = .Checkmark
                            }
                        }
                    }
                default: break
                }
            }
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
                
                //Change selection to all cells in section 1
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
    
    func copyUserDecksToSync() {
        var decksToSynchronize = [String]()
        if let userDecksArray = userDecksArray {
            for i in 0..<userDecksArray.count {
                let cell = detailTableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 1))
                if cell?.accessoryType == .Checkmark {
                    decksToSynchronize.append(userDecksArray[i].id)
                }
            }
            defaults.setObject(decksToSynchronize, forKey: Utils.NSUserDefaultsKeys.DecksToSynchronizeKey)
            //TODO: send decksToSynchronize to the Watch queue
        }
    }
    
    ///Inverses cell checkmark on/off
    func changeSelectionForCell(cell: UITableViewCell) {
        if cell.accessoryType == .None {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
    }
    
    ///Sets cell checkmark to `toState`
    func changeSelectionForCell(cell: UITableViewCell, toState: UITableViewCellAccessoryType) {
        cell.accessoryType = toState
    }
    
    //Handle tapping the Back button
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        switch mode {
        case .Frequency?:
            if defaults.boolForKey(Utils.NSUserDefaultsKeys.NotificationsEnabledKey) {
                scheduleNotification()
            }
        case .DecksForWatch?:
            copyUserDecksToSync()
        default:
            break
        }
        defaults.synchronize()
    }
    
    ///Schedules a new notification based on NSUD from now
    func scheduleNotification() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let notification = UILocalNotification()
        notification.alertBody = "Czas poćwiczyć fiszki!"
        notification.soundName = UILocalNotificationDefaultSoundName
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        var newFireDate = NSDate()
        if let type = defaults.stringForKey(Utils.NSUserDefaultsKeys.PickerFrequencyTypeKey) {
            let number = defaults.integerForKey(Utils.NSUserDefaultsKeys.PickerFrequencyNumberKey)
            switch type  {
            case "minut":
                if let newDate = calendar.dateByAddingUnit(.Minute, value: number, toDate: now, options: [.MatchStrictly]){
                    newFireDate = newDate
                }
            case "godzin":
                if let newDate = calendar.dateByAddingUnit(.Hour, value: number, toDate: now, options: [.MatchStrictly]){
                    newFireDate = newDate
                }
            case "dni":
                if let newDate = calendar.dateByAddingUnit(.Day, value: number, toDate: now, options: [.MatchStrictly]){
                    newFireDate = newDate
                }
            default: break
            }
        }
        notification.fireDate = newFireDate
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
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
            switch (indexPath.section, indexPath.row) {
            case (0, 1): height = CGFloat(140) //height of pickerView
            default: break
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
}
