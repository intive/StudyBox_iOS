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
    
    func successfulLoginTransition(){
        
            let window = UIApplication.sharedApplication().keyWindow!
            let root = window.rootViewController
            let drawerNav = root!.storyboard!.instantiateViewControllerWithIdentifier(Utils.UIIds.DrawerViewControllerId)
            drawerNav.view.backgroundColor = UIColor.grayColor()
            let center = root!.storyboard?.instantiateViewControllerWithIdentifier(Utils.UIIds.DecksViewControllerID)
            let mmDrawer = MMDrawerController(centerViewController: center, leftDrawerViewController: drawerNav)
            mmDrawer.openDrawerGestureModeMask = .None
            
            mmDrawer.closeDrawerGestureModeMask = [.PanningCenterView,.TapCenterView ]
            window.rootViewController = mmDrawer
        
    }
}
