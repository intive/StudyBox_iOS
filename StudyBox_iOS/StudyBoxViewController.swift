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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let drawer = UIApplication.sharedApplication().keyWindow?.rootViewController as? MMDrawerController {
            if let controller = navigationController?.viewControllers[0] where controller == self {
                drawer.openDrawerGestureModeMask = .None
                let hamburgerImage = UIImage(named: "Hamburger")
                let button = UIBarButtonItem(image: hamburgerImage, landscapeImagePhone: nil, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("changeDrawer"))
                
                navigationItem.leftBarButtonItem = button
            }else {
                drawer.openDrawerGestureModeMask = .PanningCenterView
            }
        }
        
        
    }
    
    func changeDrawer(){
        if let drawer = UIApplication.sharedApplication().keyWindow?.rootViewController as? MMDrawerController {
            
            if (drawer.visibleLeftDrawerWidth == 0){
                drawer.openDrawerSide(.Left, animated: true, completion: nil)
            }else {
                drawer.closeDrawerAnimated(true, completion: nil)
            }
        }
    }
  
  
}
