//
//  SBReplaceSegue.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 21.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class SBReplaceSegue: UIStoryboardSegue {
    override func perform() {
        if let mmDrawer = UIApplication.sharedRootViewController as? SBDrawerController {
            if let leftDrawer = mmDrawer.leftDrawerViewController as? DrawerViewController {
                leftDrawer.deactiveAllChildViewControllers()
                leftDrawer.tableView.reloadData()
            }
            var navigation = destinationViewController

            if !(destinationViewController is UINavigationController) {
                navigation = SBNavigationController(rootViewController: destinationViewController)
            }
            navigation.view.alpha = 0.2
            mmDrawer.setCenterViewController(navigation, withCloseAnimation: false, completion: nil)
            let source = sourceViewController
        
            UIView.animateWithDuration(0.5,
                animations: {
                    source.view.alpha = 0.2
                    navigation.view.alpha = 1
                },
                completion: { finished in
                    source.view.alpha = 1
                }
            )
        }
    }
}
