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
