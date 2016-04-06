//
//  SettingsViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class SettingsViewController: StudyBoxViewController, UITableViewDataSource, UITableViewDelegate {
    
    let settingsMainCellID = "settingsMainCell"
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let pickerFrequencyNumberKey = "pickerFrequencyNumber"
    let pickerFrequencyTypeKey = "pickerFrequencyType"
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //var cell:UITableViewCell?
        let cell = tableView.dequeueReusableCellWithIdentifier(settingsMainCellID, forIndexPath: indexPath)
        
        switch (indexPath.section,indexPath.row){
        case (0,0):
            cell.textLabel?.text = "Częstotliwość"
            if let number = defaults.stringForKey(pickerFrequencyNumberKey), let type = defaults.stringForKey(pickerFrequencyTypeKey)
            {
                cell.detailTextLabel?.text = "\(number) \(type)"
            } else {
                cell.detailTextLabel?.text = "Nie wybrano"
            }
            
        case (1,0):
            cell.textLabel?.text = "Talie"
            //TODO: set to data from NSUserDefaults
            cell.detailTextLabel?.text = "Nie wybrano"
            
        default: break
        }
        
        cell.textLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        cell.detailTextLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        return cell
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
    
    //TODO: recognize which cell was tapped
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let cell = sender as? UITableViewCell {
//            let indexPath = self.settingsTableView.indexPathForCell(cell)!
//            assert(segue.destinationViewController.isKindOfClass(SettingsDetailViewController))
//            let detailViewController = segue.destinationViewController as UITable
//            switch indexPath.inSection {
//                detailViewController.mode = .Frequency
//            }
//        }
//    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        settingsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
