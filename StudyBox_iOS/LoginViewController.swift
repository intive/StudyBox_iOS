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
    @IBOutlet weak var emailTextField: ValidatableTextField!
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
        logInButton.backgroundColor = UIColor.sb_DarkGrey()
        unregisteredUserButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        registerUserButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSource = self
    }
    
    func loginWithInputData(){
        
        let reach = Reachability.reachabilityForInternetConnection()
        let isReachable = reach.currentReachabilityStatus() != .NotReachable
        var alertMessage:String?
        
        if !isReachable {
            alertMessage = "Brak połączenia z Internetem"
        }
        
        if !passwordTextField.isValid {
            alertMessage = "Niepoprawne hasło!"
        }
        
        if !emailTextField.isValid {
            alertMessage = "Niepoprawny email!"
        }
        
        if !validateTextFieldsNotEmpty() {
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
        
        
        var resultText = (textField.text as NSString?)?.stringByReplacingCharactersInRange(range, withString: string)
        
        if let text = resultText where textField == emailTextField {
            resultText = text.trimWhiteCharacters()
            validationResult = text.isValidEmail()
            
        } else if let text = resultText where textField == passwordTextField {
            validationResult = text.isValidPassword()
            
        }
        textField.text = resultText
        
        if let validableTextField = textField as? ValidatableTextField {
            validableTextField.isValid = validationResult
        }
        
        if areTextFieldsValid() {
            logInButton.backgroundColor = UIColor.sb_Raspberry()
        } else {
            logInButton.backgroundColor = UIColor.sb_DarkGrey()
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
