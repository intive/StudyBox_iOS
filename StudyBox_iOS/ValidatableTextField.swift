//
//  ValidableTextField.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 28.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class ValidatableTextField: UITextField {
    
    var invalidMessage:String? {
        didSet {
            if invalidMessage == nil {
                textColor = validColor
            } else {
                textColor = invalidColor
            }
        }
    }
    var validColor:UIColor!
    var invalidColor:UIColor!
}

