//
//  LoginViewController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 27.02.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import Reachability 
class LoginViewController: UserViewController,InputViewControllerDataSource {

    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var emailTextField: EmailValidatableTextField!
    @IBOutlet weak var passwordTextField: ValidatableTextField!
    @IBOutlet weak var unregisteredUserButton: UIButton!
    @IBOutlet weak var registerUserButton: UIButton!
    
    var inputViews = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputViews.appendContentsOf([emailTextField,passwordTextField])
        inputViews.forEach {
            if let validable = $0 as? ValidatableTextField {
                validable.validColor = UIColor.sb_DarkBlue()
                validable.invalidColor = UIColor.sb_Raspberry()
                validable.textColor = validable.validColor
            }
        }
        
        logInButton.layer.cornerRadius = 10.0
        logInButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        disableButton(logInButton)
        unregisteredUserButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        registerUserButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSource = self
    }
    
    func loginWithInputData(){
        
        var alertMessage:String?
        
        if !Reachability.isConnected() {
            alertMessage = "Brak połączenia z Internetem"
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
            alertMessage = "Wypełnij wszystkie pola!"
        }
        
        if let message = alertMessage {
            presentAlertController(withTitle: "", message: message, buttonText: "Ok")
        } else {
            successfulLoginTransition()
        }
    }

    @IBAction func login(sender: UIButton) {
        loginWithInputData()
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var validationResult = true
        
        var invalidMessage:String?
        if let text = textField.text as NSString? {
            textField.text = text.stringByReplacingCharactersInRange(range, withString: string)
        }
        
        if textField == emailTextField, let _ = textField.text  {
            validationResult = emailTextField.isValid()
            if !validationResult {
                invalidMessage = ValidationMessage.emailIncorrect.rawValue
            }
            
        } else if textField == passwordTextField, let text = textField.text {
            validationResult = text.isValidPassword(minimumCharacters: Utils.UserAccount.MinimumPasswordLength)
            if !validationResult {
                invalidMessage = ValidationMessage.passwordIncorrect.rawValue
            }
            
        }
        
        if let validatableTextField = textField as? ValidatableTextField {
            validatableTextField.invalidMessage = invalidMessage
        }
        
        if areTextFieldsValid() {
            enableButton(logInButton)
        } else {
            disableButton(logInButton)
        }
        
        return false
        
    }
    
    @IBAction func loginWithoutAccount(sender: AnyObject) {
        successfulLoginTransition()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == passwordTextField {
            textField.resignFirstResponder()
            loginWithInputData()
            return false
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
}
