//
//  SBDrawerController+basic.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 25.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension SBDrawerController {
    static func basicSBDrawer(storyboard board: UIStoryboard) -> SBDrawerController {
        guard let drawerNav = board.instantiateViewControllerWithIdentifier(Utils.UIIds.DrawerViewControllerID) as? DrawerViewController else {
            fatalError("DrawerViewController has wrong id in the storybard")
        }
        
        guard let center = drawerNav.initialCenterController() else {
            fatalError("DrawerViewController doesn't have initial view controller")
        }
        let sbDrawer = SBDrawerController(centerViewController: center, leftDrawerViewController: drawerNav)
        sbDrawer.openDrawerGestureModeMask = .None
        sbDrawer.closeDrawerGestureModeMask = [.PanningCenterView ]
        sbDrawer.statusBarViewBackgroundColor = UIColor.defaultNavBarColor()
        sbDrawer.showsStatusBarBackgroundView = true
        
        let offset: CGFloat = 100
        
        sbDrawer.setGestureShouldRecognizeTouchBlock({ (drawer, gesture, touch) -> Bool in
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
        
        return sbDrawer
    }
}
