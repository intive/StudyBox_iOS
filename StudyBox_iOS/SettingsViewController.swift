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
import SVProgressHUD

class SettingsViewController: StudyBoxViewController, UITableViewDataSource, UITableViewDelegate, SettingsDetailVCChangeDecksDelegate {
    
    let settingsMainCellID = "settingsMainCell"
    var decksToSync = [String]()
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    lazy private var dataManager: DataManager = { return UIApplication.appDelegate().dataManager }()
    
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
        if let section = self.settingsTableView.indexPathForSelectedRow?.section,
            detailViewController = segue.destinationViewController as? SettingsDetailViewController {
            switch section {
            case 0:
                detailViewController.mode = .Frequency
            case 1:
                detailViewController.mode = .DecksForWatch
                detailViewController.delegate = self
            default: break
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        guard identifier == "showDetailVCSegue" else {
            return false
        }
        var shouldPerform = false
        
        if let section = self.settingsTableView.indexPathForSelectedRow?.section {
            switch section {
            case 0:
                shouldPerform = true
            case 1:
                if !WCSession.isSupported() {
                    SVProgressHUD.showInfoWithStatus("Twoje urządzenie nie obsługuje komunikacji z Apple Watch.")
                }
                if let email = dataManager.remoteDataManager.user?.email {
                    let userDecks = dataManager.localDataManager.filter(Deck.self, predicate: "owner = '\(email)'")
                    if userDecks.isEmpty {
                        SVProgressHUD.showInfoWithStatus("Nie masz na swoim urządzeniu żadnych talii do synchronizacji.")
                    } else { //We have decks
                        shouldPerform = true
                    }
                } else { //User is not logged in
                    SVProgressHUD.showInfoWithStatus("Musisz być zalogowany oraz posiadać talie aby synchronizować je z Apple Watch.")
                }
                if !shouldPerform {
                    self.settingsTableView.deselectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), animated: true)
                }
                
            default: break
            }
        }
        return shouldPerform
        
    }
    
    //Update cells when returning from DetailVC
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let decksFromDefaults = defaults.objectForKey(Utils.NSUserDefaultsKeys.DecksToSynchronizeKey) as? [String] {
            decksToSync = decksFromDefaults
        }
        settingsTableView.reloadData()
    }
    
    func updateDecks() {
        SVProgressHUD.show()
        if let decksToSync = defaults.objectForKey(Utils.NSUserDefaultsKeys.DecksToSynchronizeKey) as? [String] {
            guard !decksToSync.isEmpty else {
                SVProgressHUD.dismiss()
                return
            }
            WatchDataManager.watchManager.downloadSelectedDecksFlashcardsTips(decksToSync) {
                switch $0 {
                case .Success:
                    SVProgressHUD.showSuccessWithStatus("Zsynchronizowano talie z serwera.")
                    self.sendDecksToWatch(self.decksToSync)
                case .Failure:
                    SVProgressHUD.showErrorWithStatus("Błąd przy pobieraniu danych.")
                }
            }
        } else {
            SVProgressHUD.dismiss()
        }
    }
    
    func sendDecksToWatch(decksToSynchronizeIDs: [String]) {
        do {
            try WatchDataManager.watchManager.sendDecksToAppleWatch(decksToSynchronizeIDs)
        } catch let e {
            debugPrint(e)
            SVProgressHUD.showErrorWithStatus("Nie można obecnie przesłać talii do Apple Watch.")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ustawienia"
        settingsTableView.backgroundColor = UIColor.sb_Grey()
    }
}
