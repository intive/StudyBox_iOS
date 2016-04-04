//
//  SettingsViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class SettingsViewController: StudyBoxViewController, UITableViewDataSource, UITableViewDelegate {
    
    let frequencyCellID = "frequencyCell"
    let decksCellID = "decksCell"
    let pickerCellID = "pickerCell"
    var frequencyTitle = "aa"
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : return 2
        case 1 : return 1
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = tableView.rowHeight;
        if indexPath.section == 0 && indexPath.row == 1 {
            height = CGFloat(140)
        }
        return height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        switch (indexPath.section,indexPath.row){
        case (0,0): cell = tableView.dequeueReusableCellWithIdentifier(frequencyCellID, forIndexPath: indexPath)
            //cell?.detailTextLabel?.text = "częstotliwość"
        case (0,1): cell = tableView.dequeueReusableCellWithIdentifier(pickerCellID)
        case (1,0): cell = tableView.dequeueReusableCellWithIdentifier(decksCellID)
        cell?.detailTextLabel?.text = "Nie wybrano"
        default: break
        }
        
        cell?.textLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        cell?.detailTextLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        return cell!
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
        case 0 : return "Ustaw jak często chcesz otrzymywać powiadomienia z przypomnieniem o ćwiczeniach"
        case 1 : return "Wybierz które talie chcesz synchronizować ze swoim Apple Watch."
        default: return ""
        }
    }
    
    func refreshFrequencyCell(interval: String) {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let cell = settingsTableView.cellForRowAtIndexPath(indexPath)
        cell?.detailTextLabel?.text = "częstotliwość"
        self.settingsTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
