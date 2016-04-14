//
//  EmailValidatableTextField.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 04.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class EmailValidatableTextField: ValidatableTextField {

    func isValid()-> Bool {
        text = text?.trimWhiteCharacters()
        if let textToValidate = text {
            return textToValidate.isValidEmail()
        }
        return false
    }

}
