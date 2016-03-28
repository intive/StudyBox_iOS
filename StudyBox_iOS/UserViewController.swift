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
    
    var centerOffset:CGFloat = 100
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
            
            let offset = centerOffset
            
            mmDrawer.setGestureShouldRecognizeTouchBlock({ (drawer, gesture, touch) -> Bool in
                if let _ = gesture as? UIPanGestureRecognizer {
                    if (drawer.visibleLeftDrawerWidth == 0) {
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
    
    func validateEmail(text:String)->(adjustedValue:String,isValid:Bool) {
        
        // * Validation logic inherited from `RegistrationViewController` by Kacper Cz
        
        //Trim spaces at the beginning and end of email
        let adjusted = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        //Trimmed text must contain `@` but mustn't contain whitespace inside
        if (adjusted.containsString(" ") || !adjusted.containsString("@")) {
            return (adjusted,false)
        }
        return (adjusted,true)
    }
    
    
    func validatePasswordLengthAndSpaces(text:String)->Bool {
        if text.characters.count < 8 || text.rangeOfCharacterFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) != nil {
            return false
        }
        return true
    }
    
    func validateTextFieldsNotEmpty()->Bool {
        
        if let inputViews = dataSource?.inputViews {
            for field in inputViews {
                guard let text = field.text where text.characters.count > 0 else {
                    return false
                }
            }
        }

        return true
    }
    
    func textFieldsAreValid()-> Bool {
        if let inputViews = dataSource?.inputViews {
            for field in inputViews {
                if let validableField = field as? ValidableTextField {
                    if !validableField.isValid {
                        return false 
                    }
                }
            }
        }
        
        return true
    }
    
}
