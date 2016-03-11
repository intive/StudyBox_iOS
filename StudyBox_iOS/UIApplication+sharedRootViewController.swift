//
//  UIApplications+RootViewController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 10.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension UIApplication {
    class var sharedRootViewController:UIViewController? {
        get {
            return UIApplication.sharedApplication().keyWindow?.rootViewController
        }
        set {
            UIApplication.sharedApplication().keyWindow?.rootViewController = newValue
        }
    }
}
