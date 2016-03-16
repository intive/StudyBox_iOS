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
        if let text = textField.text where textField == emailTextField {
            textField.text = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
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
