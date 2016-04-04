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
            cell?.detailTextLabel?.text = "częstotliwość"
        case (0,1): cell = tableView.dequeueReusableCellWithIdentifier(pickerCellID)
        case (1,0): cell = tableView.dequeueReusableCellWithIdentifier(decksCellID)
            cell?.detailTextLabel?.text = "x wybranych"
        default: break
        }
        
        
        cell?.textLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        cell?.detailTextLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        return cell!
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Ustaw jak często chcesz otrzymywać powiadomienia z przypomnieniem o ćwiczeniach
        //Wybierz które talie chcesz synchronizować ze swoim Apple Watch.
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
