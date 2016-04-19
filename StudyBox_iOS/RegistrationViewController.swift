//
//  RegistrationViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 28.02.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import Foundation
import Reachability

var userDataForRegistration = [String : String]()

class RegistrationViewController: UserViewController, InputViewControllerDataSource {
    
    @IBOutlet weak var emailTextField: EmailValidatableTextField!
    @IBOutlet weak var passwordTextField: ValidatableTextField!
    @IBOutlet weak var repeatPasswordTextField: ValidatableTextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var inputViews = [UITextField]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* the register button is by default disabled,
         user has to enter some data and it has to be verified
         */
        disableButton(registerButton)
        registerButton.layer.cornerRadius = 10.0
        
        inputViews.append(emailTextField)
        inputViews.append(passwordTextField)
        inputViews.append(repeatPasswordTextField)
        inputViews.forEach {
            if let validable = $0 as? ValidatableTextField {
                validable.validColor = UIColor.sb_DarkBlue()
                validable.invalidColor = UIColor.sb_Raspberry()
                validable.textColor = validable.validColor
            }
        }
        emailTextField.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        passwordTextField.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        repeatPasswordTextField.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        registerButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    }
    
    
    func registerWithInputData() {
        var alertMessage:String?
        
        if !Reachability.isConnected() {
            alertMessage = ValidationMessage.noInternet.rawValue
        }
        
        for inputView in inputViews {
            if let validatableTextField = inputView as? ValidatableTextField {
                if let message = validatableTextField.invalidMessage {
                    alertMessage = message
                    break
                }
            }
        }
        
        if areTextFieldsEmpty() {
            alertMessage = ValidationMessage.fieldsAreEmpty.rawValue
        }
        
        if let message = alertMessage {
            presentAlertController(withTitle: "", message: message, buttonText: "Ok")
        } else {
            dismissViewControllerAnimated(true) {[unowned self] in
                self.successfulLoginTransition()
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var validationResult = true
        
        
        if let text = textField.text as NSString? {
            textField.text = text.stringByReplacingCharactersInRange(range, withString: string)
        }
        
        var invalidMessage:String? = nil 
        if textField == emailTextField, let _ = textField.text {
            validationResult = emailTextField.isValid()
            if !validationResult {
                invalidMessage = ValidationMessage.emailIncorrect.rawValue
            }
            
        } else if let text = textField.text {
            validationResult = text.hasMinimumCharacters(minimum: Utils.UserAccount.MinimumPasswordLength)
            
            if !validationResult {
                invalidMessage = ValidationMessage.passwordTooShort.rawValue
            } else {
                validationResult = !text.hasWhitespaceOrNewLineCharacter()
                
                if !validationResult {
                    invalidMessage = ValidationMessage.passwordIncorrect.rawValue
                } else {
                    var matchingField:UITextField?
                    
                    if textField == passwordTextField {
                        matchingField = repeatPasswordTextField
                    } else {
                        matchingField = passwordTextField
                    }
                    
                    if let validatableMatchingField = matchingField as? ValidatableTextField where validatableMatchingField.text != "" {
                        validationResult = text == validatableMatchingField.text
                        if !validationResult {
                            invalidMessage = ValidationMessage.passwordsDontMatch.rawValue
                            validatableMatchingField.invalidMessage = invalidMessage
                        }else {
                            validatableMatchingField.invalidMessage = nil
                        }
                        
                    }
                    
                }
            }
            
            
        }
        
        if let validatableTextField = textField as? ValidatableTextField {
            validatableTextField.invalidMessage = invalidMessage
        }
        
        if areTextFieldsValid() {
            enableButton(registerButton)
        } else {
            disableButton(registerButton)
        }
        
        return false
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let nextTag = textField.tag + 1
        
        // Try to find next responder
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder!
        
        if nextResponder != nil {
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so hide keyboard
            textField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func cancelRegistration(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func register(sender: UIButton) {
        registerWithInputData()
    }
}
