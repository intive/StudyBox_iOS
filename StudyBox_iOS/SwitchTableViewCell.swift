//
//  switchTableViewCell.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 08.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelOutlet: UILabel!
    @IBOutlet weak var switchOutlet: UISwitch!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBAction func switchFlipped(sender: AnyObject) {
        
        if switchOutlet.on {
            defaults.setBool(true, forKey: Utils.NSUserDefaultsKeys.notificationsEnabledKey)
        } else {
            defaults.setBool(false, forKey: Utils.NSUserDefaultsKeys.notificationsEnabledKey)
        }
    }
    
    //Set value of the switch accordingly to NSUD before appearing
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelOutlet.text = "Powiadomienia"
        labelOutlet.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        
        if defaults.boolForKey(Utils.NSUserDefaultsKeys.notificationsEnabledKey) {
            switchOutlet.setOn(true, animated: false)
        } else {
            switchOutlet.setOn(false, animated: false)
        }
    }
    
}
