//
//  LoginViewController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 27.02.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import Reachability
import SVProgressHUD

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
        
        SVProgressHUD.setDefaultMaskType(.Gradient)
        SVProgressHUD.setMinimumDismissTimeInterval(1.5)
        
        logInButton.layer.cornerRadius = 10.0
        logInButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        disableButton(logInButton)
        unregisteredUserButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        registerUserButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        
        autoLoginIfLoggedBefore()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSource = self
    }
    
    func autoLoginIfLoggedBefore() {
        let myData = UIApplication.appDelegate().dataManager.remoteDataManager.getEmailPassFromDefaults()

        if let email = myData?.email, password = myData?.password {
            loginWithInputData(email, password: password)
        }
    }
    
    func loginToServer(withEmail email: String, password: String) {
        let newDataManager = UIApplication.appDelegate().dataManager
        
        newDataManager.login(email, password: password, completion: { response in
            var errorMessage = "Błąd logowania"
            
            switch response {
            case .Success(let user):
                
                newDataManager.remoteDataManager.saveEmailPassInDefaults(user.email, pass: user.password)
                self.successfulLoginTransition()
                return
                
            case .Error(let err):
                if case .ErrorWithMessage(let txt)? = (err as? ServerError){
                    errorMessage = txt
                }
            }
            SVProgressHUD.showErrorWithStatus(errorMessage)
        })
    }
    
    func loginWithInputData(login: String? = nil, password: String? = nil) {
        
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
            SVProgressHUD.showInfoWithStatus(message)
            return
        }
        if let login = login, password = password {
            loginToServer(withEmail: login, password: password)
        } else if let email = emailTextField.text, password = passwordTextField.text  {
            loginToServer(withEmail: email, password: password)
        }
        SVProgressHUD.dismiss()
    }

    @IBAction func login(sender: UIButton) {
        SVProgressHUD.showWithStatus("Logowanie...")
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
