//
//  UIApplication+appDelegate.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 22.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension UIApplication {
    static func appDelegate() -> AppDelegate {
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        return delegate!
        
    }
}
