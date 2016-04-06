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
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let pickerFrequencyNumberKey = "pickerFrequencyNumber"
    let pickerFrequencyTypeKey = "pickerFrequencyType"
    
    let pickerFrequencyNumbers = ["1","2","3","4","5","10","15","20","30","45","60"]
    let pickerFrequencyTypes = ["minut","godzin","dni"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self

        //TODO: Set picker to data from NSUserDefaults
        
    }
    
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
    
    //Set labels and fonts of picker view
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel
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
    
    //Handle selecting a new frequency interval
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        switch component {
        case 0: defaults.setObject(pickerFrequencyNumbers[row], forKey: pickerFrequencyNumberKey)
        case 1: defaults.setObject(pickerFrequencyTypes[row], forKey: pickerFrequencyTypeKey)
        default: break
        }
    }
}
