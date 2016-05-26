//
//  TipViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 22.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import WatchKit

class TipViewController: WKInterfaceController {
    
    @IBOutlet var tipLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let tipText = context as? String {
            tipLabel.setText("Podpowiedź:\n\(tipText)")
        }
    }
}
