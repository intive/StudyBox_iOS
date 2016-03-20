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

    private var isDrawerVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if let drawer = UIApplication.sharedRootViewController as? MMDrawerController {
            if let controller = navigationController?.viewControllers[0] where controller === self {
                let hamburgerImage = UIImage(named: "Hamburger")
                let button = UIBarButtonItem(image: hamburgerImage, landscapeImagePhone: nil, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("toggleDrawer"))
                navigationItem.leftBarButtonItem = button
                drawer.openDrawerGestureModeMask = .Custom
            }else {
                drawer.openDrawerGestureModeMask = .None
            }
            
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let sbDrawer = UIApplication.sharedRootViewController as? SBDrawerController  {

            var isCenter = false
            if let centerNavigation = sbDrawer.centerViewController as? UINavigationController {
                centerNavigation.viewControllers.forEach {
                    if $0 === self {
                        isCenter = true
                    }
                }
            }else if sbDrawer.centerViewController === self  {
                isCenter = true
            }
            if (isCenter) {
                sbDrawer.centerDelegate = self
            }
        }
    }
    
    func toggleDrawer(){
        if let drawer = UIApplication.sharedRootViewController as? MMDrawerController {
            drawer.toggleDrawerSide(.Left, animated: true,completion: { (_) in
            })
  
        }
    }
    
    func showingDrawer() {
        isDrawerVisible = !isDrawerVisible
        UIView.animateWithDuration(SBDrawerController.statusBarAnimationTime, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }) { (_) in
            self.isDrawerVisible = !self.isDrawerVisible
        }
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }
    override func prefersStatusBarHidden() -> Bool {
        return isDrawerVisible
    }
  
}
