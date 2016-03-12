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
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var loginTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var repeatPasswordTextField: UITextField!
  @IBOutlet weak var registerButtonOutlet: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var studyBoxImage: UIImageView!
  
  var userDataForRegistration = [String : String]()
  
  var inputViews = [UITextField]()
  let studyBoxRedColor = UIColor(red: 0.87890625, green: 0.1640625, blue: 0.3203125, alpha: 1.0)
  let studyBoxBlueColor = UIColor(red: 23/255, green: 82/255, blue: 165/255, alpha: 1.0)
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    dataSource = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /* the login button is by default disabled,
    user has to enter some data and it has to be verified
    */
    registerButtonOutlet.enabled = false
    registerButtonOutlet.backgroundColor = UIColor.grayColor()
    registerButtonOutlet.layer.cornerRadius = 10.0
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    
    inputViews.append(loginTextField)
    inputViews.append(emailTextField)
    inputViews.append(passwordTextField)
    inputViews.append(repeatPasswordTextField)
    
    loginTextField.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    emailTextField.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    passwordTextField.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    repeatPasswordTextField.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    registerButtonOutlet.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    cancelButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
  }
  
  func keyboardWillShow(sender: NSNotification) {
    let userInfo: [NSObject : AnyObject] = sender.userInfo!
    
    let keyboardHeight: CGFloat = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size.height
    
    self.scrollView.contentOffset = CGPointMake(0, keyboardHeight / 2)
  }
  
  func keyboardWillHide(sender: NSNotification) {
    self.scrollView.contentOffset = CGPointZero
  }
  
  func checkEmail(textField: UITextField) -> () {
    let text = textField.text
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let result = emailTest.evaluateWithObject(text)
    
    if !result {
      textField.textColor = UIColor.redColor()
      disableRegisterButton()
    }
    else {
      //TODO: check if email exists in database, if not then emailIsTakenAlert() and code below
      textField.textColor = studyBoxBlueColor
      enableRegisterButton()
    }
  }
  
  func checkPasswordLengthAndSpaces(password: UITextField) {
    if let characterCount = password.text?.characters.count {
      if characterCount < 8 {
        passwordTooShortAlert()
      }
    }
    
    if (password.text?.containsString(" ") == true) {
      passwordContainsSpaceAlert()
    }
  }
  
  func checkPasswordsMatch(password1 password1:UITextField, password2:UITextField) {
    
    if (password1.text != "" && password2.text != "") {
      if (password1.text != password2.text){
        password1.textColor = UIColor.redColor()
        password2.textColor = UIColor.redColor()
        passwordsDontMatchAlert()
        disableRegisterButton()
      }
      else {
        password1.textColor = studyBoxBlueColor
        password2.textColor = studyBoxBlueColor
        
        enableRegisterButton()
      }
    } else {
      disableRegisterButton()
    }
    
    
  }
  
  func textFieldDidEndEditing(editedTextField: UITextField) {
    
    switch editedTextField {
      
    case emailTextField:
      checkEmail(editedTextField)
      checkPasswordsMatch(password1: passwordTextField, password2: repeatPasswordTextField)
      
    case passwordTextField:
      checkPasswordLengthAndSpaces(passwordTextField)
      
    case repeatPasswordTextField:
      checkPasswordsMatch(password1: passwordTextField, password2: repeatPasswordTextField)
      
    default:
      return
    }
    
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    let nextTag=textField.tag+1;
    
    // Try to find next responder
    let nextResponder=textField.superview?.viewWithTag(nextTag) as UIResponder!
    
    if (nextResponder != nil){
      // Found next responder, so set it.
      nextResponder?.becomeFirstResponder()
    }
    else
    {
      // Not found, so hide keyboard
      textField.resignFirstResponder()
    }
    return false
  }
  
  @IBAction func cancelRegistration(sender: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func register(sender: UIButton) {
    
    if (loginTextField.text != "" &&
      emailTextField.text != "" &&
      passwordTextField.text != "" &&
      repeatPasswordTextField.text != "") {
        userDataForRegistration["username"] = loginTextField.text
        userDataForRegistration["email"] = emailTextField.text
        userDataForRegistration["password"] = repeatPasswordTextField.text
        
        //TODO: pass over the dictionary with data
        dismissViewControllerAnimated(true) {[unowned self] () -> Void in
          self.successfulLoginTransition() }
    }
    else {
      return
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func disableRegisterButton() {
    registerButtonOutlet.backgroundColor = UIColor.grayColor()
    registerButtonOutlet.enabled = false
  }
  
  func enableRegisterButton() {
    registerButtonOutlet.backgroundColor = studyBoxRedColor
    registerButtonOutlet.enabled = true
  }
  
  func passwordTooShortAlert() {
    
    let alertController = UIAlertController(title: "Za krótkie hasło",
      message: "Hasło musi mieć co najmniej 8 znaków.",
      preferredStyle: .Alert)
    
    let actionOk = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alertController.addAction(actionOk)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func passwordsDontMatchAlert() {
    
    let alertController = UIAlertController(title: "Hasła są różne",
      message: "Oba hasła muszą być identyczne.",
      preferredStyle: .Alert)
    
    let actionOk = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alertController.addAction(actionOk)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func emailIsTakenAlert() {
    
    let alertController = UIAlertController(title: "Adres e-mail zajęty",
      message: "Już istnieje konto z takim adresem e-mail.",
      preferredStyle: .Alert)
    
    let actionOk = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alertController.addAction(actionOk)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func passwordContainsSpaceAlert() {
    
    let alertController = UIAlertController(title: "Spacja w haśle",
      message: "Hasło hasło nie może zawierać spacji.",
      preferredStyle: .Alert)
    
    let actionOk = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alertController.addAction(actionOk)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
}
