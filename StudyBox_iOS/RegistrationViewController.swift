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
        
        //the register button is by default disabled, user has to enter some data and it has to be verified
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
        var alertMessage: String?
        
        if !Reachability.isConnected() {
            alertMessage = ValidationMessage.NoInternet.rawValue
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
            alertMessage = ValidationMessage.FieldsAreEmpty.rawValue
        }
        
        if let message = alertMessage {
            presentAlertController(withTitle: "", message: message, buttonText: "Ok")
        } else {
            
            if let email = emailTextField.text, password = passwordTextField.text {
                userAction(.Register, email: email, password: password)
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text as NSString? {
            textField.text = text.stringByReplacingCharactersInRange(range, withString: string)
        }
        
        var invalidMessage: String? = nil
        if textField == emailTextField, let _ = textField.text {
            if !emailTextField.isValid() {
                invalidMessage = ValidationMessage.EmailIncorrect.rawValue
            }
            
        } else if let text = textField.text {
            if !text.hasMinimumCharacters(minimum: Utils.UserAccount.MinimumPasswordLength) {
                invalidMessage = ValidationMessage.PasswordTooShort.rawValue
            } else {

                if text.hasWhitespaceOrNewLineCharacter() {
                    invalidMessage = ValidationMessage.PasswordIncorrect.rawValue
                } else {
                    var matchingField: UITextField?

                    matchingField = textField == passwordTextField ? repeatPasswordTextField : passwordTextField

                    if let validatableMatchingField = matchingField as? ValidatableTextField where validatableMatchingField.text != "" {
                        if text == validatableMatchingField.text {
                            validatableMatchingField.invalidMessage = nil
                        } else {
                            invalidMessage = ValidationMessage.PasswordsDontMatch.rawValue
                            validatableMatchingField.invalidMessage = invalidMessage
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
