//
//  SBNavigationController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 09.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class SBNavigationController: UINavigationController {

    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return childViewControllers.last
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
