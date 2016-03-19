//
//  RegistrationViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 28.02.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import Foundation

class RegistrationViewController: UserViewController, InputViewControllerDataSource {
  
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var repeatPasswordTextField: UITextField!
  @IBOutlet weak var registerButtonOutlet: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  
  var inputViews = [UITextField]()
  let studyBoxRedColor = UIColor(red: 0.87890625, green: 0.1640625, blue: 0.3203125, alpha: 1.0)
  let studyBoxBlueColor = UIColor(red: 23/255, green: 82/255, blue: 165/255, alpha: 1.0)
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /* the login button is by default disabled,
    user has to enter some data and it has to be verified
    */
    registerButtonOutlet.enabled = false
    registerButtonOutlet.backgroundColor = UIColor.grayColor()
    registerButtonOutlet.layer.cornerRadius = 10.0
    dataSource = self
    inputViews.append(emailTextField)
    inputViews.append(passwordTextField)
    inputViews.append(repeatPasswordTextField)
    
    emailTextField.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    passwordTextField.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    repeatPasswordTextField.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    registerButtonOutlet.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    cancelButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
  }

  
  func checkEmail(textField: UITextField) -> () {
    let text = textField.text
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let result = emailTest.evaluateWithObject(text)
    
    if !result {
      textField.textColor = UIColor.redColor()
      registerButtonOutlet.backgroundColor = UIColor.grayColor()
      registerButtonOutlet.enabled = false
    }
    else {
      textField.textColor = studyBoxBlueColor
      registerButtonOutlet.backgroundColor = studyBoxRedColor
      registerButtonOutlet.enabled = true
    }
  }
  
  func checkPasswords(password1 password1:UITextField, password2:UITextField) {
    if password1.text != password2.text{
      password1.textColor = UIColor.redColor()
      password2.textColor = UIColor.redColor()
      registerButtonOutlet.backgroundColor = UIColor.grayColor()
      registerButtonOutlet.enabled = false
    }
    else {
      password1.textColor = studyBoxBlueColor
      password2.textColor = studyBoxBlueColor
      registerButtonOutlet.backgroundColor = studyBoxRedColor
      registerButtonOutlet.enabled = true
    }
  }
  
  func textFieldDidEndEditing(editedTextField: UITextField) {
    
    switch editedTextField {
    case emailTextField:
      checkEmail(editedTextField)
    case repeatPasswordTextField:
      checkPasswords(password1: passwordTextField, password2: repeatPasswordTextField)
    default:
      return
    }
    
    
  }
    
  
    @IBAction func cancelRegistration(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func register(sender: UIButton) {
        dismissViewControllerAnimated(true) {[unowned self] () -> Void in
            self.successfulLoginTransition()

        }
    }
    
}
