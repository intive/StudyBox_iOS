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
import SVProgressHUD

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
    
    func registerNewUser(email: String, password: String) {
        SVProgressHUD.show()
        let dataManager = UIApplication.appDelegate().dataManager
        
        dataManager.register(email, password: password, completion: { response in
            var errorMessage = "Błąd Rejestracji"
            let successfullMessageTitle = "Zarejestrowano pomyślnie"
            let successfullMessage = "Za chwilę nastąpi automatyczne zalogowanie"
            let ok = "Ok"
            
            switch response {
            case .Success(let user):
                
                debugPrint("email: \(user.email)")
                debugPrint("password: \(user.password)")
                

                let alert: UIAlertController = UIAlertController(title: successfullMessageTitle, message: successfullMessage, preferredStyle: .Alert)
                
                func dismissAlert(){
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }
                
                self.presentViewController(alert, animated: true, completion: nil)
                
                let delay = 3.0 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), {
                    SVProgressHUD.dismiss()
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    dataManager.remoteDataManager.saveEmailPassInDefaults(user.email, pass: user.password)
                    self.successfulLoginTransition()
                })
                
            case .Error(let err):
                if case .ErrorWithMessage(let txt)? = (err as? ServerError){
                    errorMessage = txt
                }
                SVProgressHUD.showErrorWithStatus(errorMessage)
            }
        })
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
            SVProgressHUD.showErrorWithStatus(message)
        } else {
            if let email = self.emailTextField.text, password = self.passwordTextField.text  {
                inputViews.forEach { $0.resignFirstResponder() }
                self.registerNewUser(email, password: password)
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
