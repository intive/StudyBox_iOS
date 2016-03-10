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
    var inputViews = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputViews.append(emailTextField)
        inputViews.append(passwordTextField)
        logInButton.layer.cornerRadius = 10.0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSource = self
    }

    @IBAction func login(sender: UIButton) {
        //dummy login
        successfulLoginTransition()
    }
    @IBAction func loginWithoutAccount(sender: AnyObject) {
        successfulLoginTransition()
    }
}
