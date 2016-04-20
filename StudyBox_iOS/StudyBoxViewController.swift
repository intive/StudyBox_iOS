//
//  StudyBoxViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import MMDrawerController
//View Controller, which will be inherited by other VC's

class StudyBoxViewController: UIViewController, SBDrawerCenterDelegate {

    var isDrawerVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if let drawer = UIApplication.sharedRootViewController as? MMDrawerController {
            if let controller = navigationController?.viewControllers[0] where controller === self {
                let hamburgerImage = UIImage(named: "Hamburger")
                let button = UIBarButtonItem(image: hamburgerImage, landscapeImagePhone: nil, style: UIBarButtonItemStyle.Plain,
                                             target: self, action: #selector(StudyBoxViewController.toggleDrawer))
                navigationItem.leftBarButtonItem = button
                drawer.openDrawerGestureModeMask = .Custom
            } else {
                drawer.openDrawerGestureModeMask = .None
            }
        }
    }
    
    func toggleDrawer(){
        if let drawer = UIApplication.sharedRootViewController as? MMDrawerController {
            drawer.toggleDrawerSide(.Left, animated: true, completion: nil)
        }
    }
    
    func updateStatusBar() {
        if let navigationController = self.navigationController {
            navigationController.setNeedsStatusBarAppearanceUpdate()
        } else {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func drawerToggleAnimation() {
        isDrawerVisible = !isDrawerVisible
        var animationTime: NSTimeInterval!
        if let drawer = UIApplication.sharedRootViewController as? SBDrawerController {
            animationTime = drawer.drawerAnimationTime
        }
        UIView.animateWithDuration(animationTime,
            animations: {
                self.updateStatusBar()
            })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if isDrawerVisible {
            return .LightContent
        }
        return .Default
    }
}
