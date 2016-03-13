//
//  LoginViewController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 27.02.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
class LoginViewController: UserViewController,InputViewControllerDataSource {

    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var unregisteredUserButton: UIButton!
    @IBOutlet weak var registerUserButton: UIButton!
    
    var inputViews = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputViews.append(emailTextField)
        inputViews.append(passwordTextField)
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
    
    func login(){
        if let emailText = emailTextField.text, let passwordText = passwordTextField.text where emailText != "" && passwordText != "" {
            successfulLoginTransition()
        }else {
            let faultAlert = UIAlertController(title: "", message: "Wypełnij wszystkie pola!", preferredStyle: .Alert)
            faultAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler:nil ))
            presentViewController(faultAlert, animated: true, completion: nil)
        }
    }

    @IBAction func login(sender: UIButton) {
        login()
    }
    
    
    
    @IBAction func loginWithoutAccount(sender: AnyObject) {
        successfulLoginTransition()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == emailTextField {
            if let text = textField.text {
                textField.text = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                
            }
        }
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == passwordTextField {
            textField.resignFirstResponder()
            login()
            return false
        }else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
}
