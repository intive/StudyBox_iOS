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

class StudyBoxViewController: UIViewController {

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
    
    
    func toggleDrawer(){
        if let drawer = UIApplication.sharedRootViewController as? MMDrawerController {
            if (drawer.openSide == .None){
                isDrawerVisible = true
            }else {
                isDrawerVisible = false
            }
            drawer.toggleDrawerSide(.Left, animated: true,completion: {[weak self] (_) in
                if let strongSelf = self {
                    strongSelf.isDrawerVisible = !strongSelf.isDrawerVisible
                }
            })
            
        }
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }
    override func prefersStatusBarHidden() -> Bool {
        return isDrawerVisible
    }
  
}
