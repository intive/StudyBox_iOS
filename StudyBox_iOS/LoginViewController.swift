//
//  LoginViewController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 27.02.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class LoginViewController: InputViewController,InputViewControllerDataSource {

    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var inputViews:[UITextField]! = [UITextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputViews.append(emailTextField)
        inputViews.append(passwordTextField)
        logInButton.layer.cornerRadius = CGFloat(10)
        dataSource = self
        
    }

}
