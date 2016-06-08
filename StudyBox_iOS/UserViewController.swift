//
//  UserViewController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 06.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import MMDrawerController
class UserViewController: InputViewController {
    
    func successfulLoginTransition(){

        if let board = storyboard {
            
            UIApplication.sharedRootViewController = SBDrawerController.basicSBDrawer(storyboard: board)
        }
    }
    
    func areTextFieldsEmpty() -> Bool {
        
        if let inputViews = dataSource?.inputViews {
            for field in inputViews {
                if field.isEmpty() {
                    return true
                }
            }
        }
        return false 
    }
    
    func areTextFieldsValid() -> Bool {
        if let inputViews = dataSource?.inputViews {
            for field in inputViews {
                if let validatableField = field as? ValidatableTextField {
                    if validatableField.isEmpty() || validatableField.invalidMessage != nil {
                        return false 
                    }
                }
            }
        }
        return true
    }
    
    func disableButton(button: UIButton) {
        button.backgroundColor = UIColor.sb_DarkGrey()
    }
    
    func enableButton(button: UIButton) {
        button.backgroundColor = UIColor.sb_Raspberry()
    }
    
    enum ValidationMessage: String  {
        case PasswordTooShort = "Hasła są zbyt krótkie"
        case PasswordsDontMatch = "Hasła nie są jednakowe!"
        case PasswordContainsSpace = "Nie można użyć w haśle białych znaków!"
        case PasswordIncorrect = "Niepoprawne hasło"
        case NoInternet = "Brak połączenia z Internetem"
        case EmailIncorrect = "Niepoprawny e-mail!"
        case FieldsAreEmpty = "Wypełnij wszystkie pola!"
    }
    
}
