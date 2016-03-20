//
//  UIApplication+replaceDrawerCenter.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 20.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import MMDrawerController
extension UIApplication {
    
    class func replaceCurrentCenter(withViewController viewController: UIViewController, embedInNavigationController: Bool) {
        if let mmDrawer = UIApplication.sharedRootViewController as? MMDrawerController{
            var controller:UIViewController?
            if (embedInNavigationController) {
                controller = UINavigationController(rootViewController: viewController)
            }else {
                controller = viewController
            }
            if let leftDrawer = mmDrawer.leftDrawerViewController as? DrawerViewController {
                leftDrawer.deactiveAllChildViewControllers()
                leftDrawer.tableView.reloadData()
            }
            mmDrawer.openDrawerSide(.Left, animated: true, completion: { (success) -> Void in
                mmDrawer.setCenterViewController(controller, withCloseAnimation: true, completion: nil)
            })

        }
    }
}
