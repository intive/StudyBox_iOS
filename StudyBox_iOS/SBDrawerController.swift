//
//  SBDrawerController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 20.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import MMDrawerController
protocol SBDrawerLeftDelegate {
    func hidingDrawer()
}
protocol SBDrawerCenterDelegate {
    func showingDrawer()
}

class SBDrawerController:MMDrawerController {
    var drawerDelegate:SBDrawerLeftDelegate?
    var centerDelegate:SBDrawerCenterDelegate?
    
    static var statusBarAnimationTime = 0.5
    
    override var centerViewController: UIViewController! {
        didSet {
            if let delegate = centerViewController as? SBDrawerCenterDelegate {
                centerDelegate = delegate
            }else {
                centerDelegate = nil 
            }
        }
    }
    
    override var leftDrawerViewController: UIViewController! {
        didSet {
            if let delegate = leftDrawerViewController as? SBDrawerLeftDelegate {
                drawerDelegate = delegate 
            }else {
                drawerDelegate = nil
            }
        }
    }
    
    override func closeDrawerAnimated(animated: Bool, velocity: CGFloat, animationOptions options: UIViewAnimationOptions, completion: ((Bool) -> Void)!) {
        drawerDelegate?.hidingDrawer()
        super.closeDrawerAnimated(animated, velocity: velocity, animationOptions: options, completion: completion)
        
    }
    
    override func openDrawerSide(drawerSide: MMDrawerSide, animated: Bool, completion: ((Bool) -> Void)!) {
        centerDelegate?.showingDrawer()
        super.openDrawerSide(drawerSide, animated: animated, completion: completion)
    }
    
}
