//
//  PickerTableViewCell.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    
    let pickerFrequencyNumbers = ["1","2","3","4","5","10","15","20","30","45","60"]
    let pickerFrequencyTypes = ["minut","godzin","dni"]
    var settingsVC = SettingsViewController()
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return pickerFrequencyNumbers.count
        case 1: return pickerFrequencyTypes.count
        default: return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel;
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }
        
        switch component {
        case 0: pickerLabel?.text = pickerFrequencyNumbers[row]
        case 1: pickerLabel?.text = pickerFrequencyTypes[row]
        default: break
        }
        
        return pickerLabel!
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        if let cell = settingsVC.settingsTableView?.cellForRowAtIndexPath(indexPath) {
            cell.detailTextLabel?.text = "updated text"
            print("a")
        }
        //TODO save to NSUserDefaults
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
        if let aView: UIView = self.superview {
            settingsVC.settingsTableView = aView as? UITableView
        }
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
