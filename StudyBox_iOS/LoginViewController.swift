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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var unregisteredUserButton: UIButton!
    @IBOutlet weak var registerUserButton: UIButton!
    
    var shouldAllowTextFieldEdition = true
    var inputViews = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputViews.appendContentsOf([emailTextField,passwordTextField])
        inputViews.forEach {
            $0.textColor = UIColor.sb_DarkBlue()
        }
        
        logInButton.layer.cornerRadius = 10.0
        logInButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        logInButton.backgroundColor = UIColor.sb_Raspberry()
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
        
        if isReachable {
            if let emailText = emailTextField.text, let passwordText = passwordTextField.text where emailText != "" && passwordText != "" {
                successfulLoginTransition()
            }else {
                presentAlertController(withTitle: "", message: "Wypełnij wszystkie pola!", buttonText: "Ok")
            }
        }else {
            presentAlertController(withTitle: "", message: "Brak połączenia z Internetem", buttonText: "Ok")
        }
    }

    @IBAction func login(sender: UIButton) {
        loginWithInputData()
    }
    
    
    
    @IBAction func loginWithoutAccount(sender: AnyObject) {
        successfulLoginTransition()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        var message:String?
        if let text = textField.text where textField == emailTextField {
            let validation = validateEmail(text)
            textField.text = validation.adjustedValue
            if !validation.isValid {
                message = "Niepoprawny e-mail!"
            }
        }else if let text = textField.text where textField == passwordTextField {
            
            if !validatePasswordLengthAndSpaces(text) {
                message = "Niepoprawne hasło!"
                
            }
        }
        if let alertMessage = message where shouldAllowTextFieldEdition {
            shouldAllowTextFieldEdition = false
            presentAlertController(withTitle: "", message: alertMessage, buttonText: "Ok",actionCompletion: {
                self.shouldAllowTextFieldEdition = true
            })
        }
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == passwordTextField {
            textField.resignFirstResponder()
            loginWithInputData()
            return false
        }else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
}
