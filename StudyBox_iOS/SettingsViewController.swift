//
//  SettingsViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import WatchConnectivity

class SettingsViewController: StudyBoxViewController, UITableViewDataSource, UITableViewDelegate {
    
    let settingsMainCellID = "settingsMainCell"
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    lazy private var dataManager: DataManager? = { return UIApplication.appDelegate().dataManager }()
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        
        switch (indexPath.section,indexPath.row){
        case (0, 0):
            //Frequency cell configuration
            cell = tableView.dequeueReusableCellWithIdentifier(settingsMainCellID, forIndexPath: indexPath)
            cell.textLabel?.text = "Powiadomienia co..."
            //Set detail label to data from NSUD
            if defaults.boolForKey(Utils.NSUserDefaultsKeys.NotificationsEnabledKey) {
                if let number = defaults.stringForKey(Utils.NSUserDefaultsKeys.PickerFrequencyNumberKey),
                    let type = defaults.stringForKey(Utils.NSUserDefaultsKeys.PickerFrequencyTypeKey)
                {
                    cell.detailTextLabel?.text = "\(number) \(type)"
                } else {
                    cell.detailTextLabel?.text = "Nie wybrano"
                }
            } else {
                cell.detailTextLabel?.text = "Wyłączone"
            }
            
        case (1, 0):
            //Deck choice cell configuration
            cell = tableView.dequeueReusableCellWithIdentifier(settingsMainCellID, forIndexPath: indexPath)
            cell.textLabel?.text = "Talie"
            if let decksCount = defaults.objectForKey(Utils.NSUserDefaultsKeys.DecksToSynchronizeKey)?.count {
                cell.detailTextLabel?.text = "\(decksCount) talii"
            } else {
                cell.detailTextLabel?.text = "Nie wybrano"
            }
            
            //TODO: enable or disable cell based on whether Watch is available
//            if WCSession.isSupported() {
//                let watchSession = WCSession.defaultSession()
//                if !watchSession.paired || !watchSession.watchAppInstalled {
//                    cell.textLabel?.textColor = UIColor.sb_Grey()
//                    cell.userInteractionEnabled = false
//                }
//            }
            
            
        default: break
        }
        
        cell.textLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        cell.detailTextLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        cell.backgroundColor = UIColor.sb_White()
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0 : return "Powiadomienia"
        case 1 : return "Apple Watch"
        default: return ""
        }
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0 : return "Ustaw jak często chcesz otrzymywać powiadomienia z przypomnieniem o ćwiczeniach."
        case 1 :
            var footer = String()
            if WCSession.isSupported() {
                let watchSession = WCSession.defaultSession()
                if !watchSession.paired {
                    footer = "Nie masz sparowanego Apple Watch na który możnaby wysłać fiszki."
                } else if !watchSession.watchAppInstalled {
                    footer = "Na twoim Apple Watch nie ma zainstalowanej aplikacji StudyBox."
                } else {
                    footer = "Wybierz które talie chcesz synchronizować ze swoim Apple Watch."
                }
            } else {
                footer = "Twoje urządzenie nie obsługuje Apple Watch."
            }
            return footer
        default: return ""
        }
    }
    
    //Set the mode of SettingsDetailVC based on tapped cell
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailViewController = segue.destinationViewController as? SettingsDetailViewController
        if let section = self.settingsTableView.indexPathForSelectedRow?.section {
            switch section {
            case 0:
                detailViewController?.mode = .Frequency
            case 1:
                detailViewController?.mode = .DecksForWatch
            default: break
            }
        }
    }
    
    //Check if user has any decks on device before performing segue on second TableViewCell
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        var doesUserHaveDecks = true
        if let userDecks = dataManager?.decks(false) {
            if userDecks.isEmpty {
                presentAlertController(withTitle: "Brak talii", message: "Nie masz na swoim urządzeniu żadnych talii do synchronizacji.", buttonText: "OK")
                doesUserHaveDecks = false
                self.settingsTableView.deselectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), animated: true)
            }
        }
        return doesUserHaveDecks
    }
    
    //Update cells when returning from DetailVC
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        settingsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ustawienia"
        settingsTableView.backgroundColor = UIColor.sb_Grey()
    }
}
