//
//  SettingsViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import Swifternalization
import WatchConnectivity

class SettingsViewController: StudyBoxViewController, UITableViewDataSource, UITableViewDelegate {
    
    let settingsMainCellID = "settingsMainCell"
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    lazy private var dataManager: NewDataManager = { return UIApplication.appDelegate().dataManager }()
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        switch (indexPath.section, indexPath.row){
        case (0, 0):
            //Frequency cell configuration
            cell = tableView.dequeueReusableCellWithIdentifier(settingsMainCellID, forIndexPath: indexPath)
            cell.textLabel?.text = "Powiadomienia co"
            //Set detail label to data from NSUD
            if defaults.boolForKey(Utils.NSUserDefaultsKeys.NotificationsEnabledKey) {
                if let number = defaults.stringForKey(Utils.NSUserDefaultsKeys.PickerFrequencyNumberKey),
                    type = defaults.stringForKey(Utils.NSUserDefaultsKeys.PickerFrequencyTypeKey)
                {
                    cell.detailTextLabel?.text = "\(number) \(I18n.localizedString(type, stringValue: number))"
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
                cell.detailTextLabel?.text = "\(decksCount) \(I18n.localizedString("amount-decks", intValue: decksCount))"
            } else {
                cell.detailTextLabel?.text = "Nie wybrano"
            }
            
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
        case 1 : return "Wybierz które talie chcesz synchronizować ze swoim Apple Watch."
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
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        var shouldPerformSegue = true
        var message: (title: String, body: String)?
        
        let userDecks = dataManager.localDataManager.getAll(Deck)
        if  userDecks.isEmpty {
            message = (title: "Brak talii", body: "Nie masz na swoim urządzeniu żadnych talii do synchronizacji.")
        }
        
        if !WCSession.isSupported() {
            message = (title: "Niekompatybilne urządzenie", body: "Twoje urządzenie nie obsługuje komunikacji z Apple Watch")
        }
        
        if let message = message {
            shouldPerformSegue = false
            presentAlertController(withTitle: message.title, message: message.body, buttonText: "OK")
            self.settingsTableView.deselectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), animated: true)
        }
        return shouldPerformSegue
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
