//
//  LoginViewController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 27.02.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import Reachability 
class LoginViewController: UserViewController, InputViewControllerDataSource {

    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var emailTextField: EmailValidatableTextField!
    @IBOutlet weak var passwordTextField: ValidatableTextField!
    @IBOutlet weak var unregisteredUserButton: UIButton!
    @IBOutlet weak var registerUserButton: UIButton!
    
    var inputViews = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputViews.appendContentsOf([emailTextField, passwordTextField])
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
    
    func loginToServer(withEmail email: String, password: String) {
        let newDataManager = UIApplication.appDelegate().newDataManager
        
        newDataManager.login(email, password: password, completion: { response in
            var msg = "Błąd logowania"
            
            switch response {
            case .Success(let usr):
                
                guard let user = usr else {
                    break
                }
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(user.email, forKey: Utils.NSUserDefaultsKeys.LoggedUserEmail)
                defaults.setObject(user.password, forKey: Utils.NSUserDefaultsKeys.LoggedUserPassword)
                self.successfulLoginTransition()
                return
                
            case .Error(let err):
                if case .ErrorWithMessage(let txt)? = (err as? ServerError){
                    msg = txt
                }
            }
            self.presentAlertController(withTitle: "", message: msg, buttonText: "Ok")
        })
    }
    
    func loginWithInputData(){
        
        var alertMessage: String?
        
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
            return
        }
        guard let email = emailTextField.text, password = passwordTextField.text else {
            return
        }
        loginToServer(withEmail: email, password: password)
        
    }

    @IBAction func login(sender: UIButton) {
        loginWithInputData()
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var validationResult = true
        
        var invalidMessage: String?
        if let text = textField.text as NSString? {
            textField.text = text.stringByReplacingCharactersInRange(range, withString: string)
        }
        
        if textField == emailTextField, let _ = textField.text  {
            validationResult = emailTextField.isValid()
            if !validationResult {
                invalidMessage = ValidationMessage.EmailIncorrect.rawValue
            }
            
        } else if textField == passwordTextField, let text = textField.text {
            validationResult = text.isValidPassword(minimumCharacters: Utils.UserAccount.MinimumPasswordLength)
            if !validationResult {
                invalidMessage = ValidationMessage.PasswordIncorrect.rawValue
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
