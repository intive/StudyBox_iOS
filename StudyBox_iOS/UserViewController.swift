//
//  UserViewController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 06.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import MMDrawerController
class UserViewController: InputViewController {
    
    var centerOffset: CGFloat = 100
    func successfulLoginTransition(){

        if let board = storyboard {
            guard let drawerNav = board.instantiateViewControllerWithIdentifier(Utils.UIIds.DrawerViewControllerId) as? DrawerViewController else {
                fatalError("DrawerViewController has wrong id in the storybard")
            }
            
            guard let center = drawerNav.initialCenterController() else {
                fatalError("DrawerViewController doesn't have initial view controller")
            }            
            let mmDrawer = SBDrawerController(centerViewController: center, leftDrawerViewController: drawerNav)
            mmDrawer.openDrawerGestureModeMask = .None
            mmDrawer.closeDrawerGestureModeMask = [.PanningCenterView ]
            mmDrawer.statusBarViewBackgroundColor = UIColor.defaultNavBarColor()
            mmDrawer.showsStatusBarBackgroundView = true 

            let offset = centerOffset
            
            mmDrawer.setGestureShouldRecognizeTouchBlock({ (drawer, gesture, touch) -> Bool in
                if let _ = gesture as? UIPanGestureRecognizer {
                    if drawer.visibleLeftDrawerWidth.isZero {
                        let touchLocation = touch.locationInView(drawer.centerViewController.view)
                        let center = drawer.centerViewController.view.center
                        if touchLocation.x < center.x + offset && touchLocation.x > center.x - offset {
                            return true
                        }
                    }
                }
                return false
            })
            
            UIApplication.sharedRootViewController = mmDrawer
        }
    }
    
    func userAction(action: UserAction, email: String, password: String) {
        let newDataManager = UIApplication.appDelegate().dataManager
        
        newDataManager.userAction(action, email: email, password: password, completion: { response in
            var errorMessage = "Błąd logowania"
            
            if case .Register = action {
                errorMessage = "Błąd rejestracji"
            }
            
            switch response {
            case .Success(let user):
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(user.email, forKey: Utils.NSUserDefaultsKeys.LoggedUserEmail)
                defaults.setObject(user.password, forKey: Utils.NSUserDefaultsKeys.LoggedUserPassword)
                
                switch action {
                case .Login:
                    self.successfulLoginTransition()

                case .Register:
                    self.dismissViewControllerAnimated(true) {[unowned self] in
                        self.successfulLoginTransition()
                    }
                }
                
                return
                
            case .Error(let err):
                if case .ErrorWithMessage(let txt)? = (err as? ServerError){
                    errorMessage = txt
                }
            }
            self.presentAlertController(withTitle: "", message: errorMessage, buttonText: "Ok")
        })
    }
    
    func areTextFieldsEmpty() -> Bool {
        
        if let inputViews = dataSource?.inputViews {
            for field in inputViews {
                if field.isEmpty() {
                    return true
                }
            }
        }
        return false 
    }
    
    func areTextFieldsValid() -> Bool {
        if let inputViews = dataSource?.inputViews {
            for field in inputViews {
                if let validatableField = field as? ValidatableTextField {
                    if validatableField.isEmpty() || validatableField.invalidMessage != nil {
                        return false 
                    }
                }
            }
        }
        return true
    }
    
    func disableButton(button: UIButton) {
        button.backgroundColor = UIColor.sb_DarkGrey()
    }
    
    func enableButton(button: UIButton) {
        button.backgroundColor = UIColor.sb_Raspberry()
    }
    
    enum ValidationMessage: String  {
        case PasswordTooShort = "Hasła są zbyt krótkie"
        case PasswordsDontMatch = "Hasła nie są jednakowe!"
        case PasswordContainsSpace = "Nie można użyć w haśle białych znaków!"
        case PasswordIncorrect = "Niepoprawne hasło"
        case NoInternet = "Brak połączenia z Internetem"
        case EmailIncorrect = "Niepoprawny e-mail!"
        case FieldsAreEmpty = "Wypełnij wszystkie pola!"
    }
    
}
