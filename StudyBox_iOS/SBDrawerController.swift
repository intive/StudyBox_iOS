//
//  SBDrawerController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 20.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import MMDrawerController

protocol SBDrawerCenterDelegate {
    var isDrawerVisible: Bool {get set}
    func drawerToggleAnimation()
}

class SBDrawerController: MMDrawerController {
    
    var centerDelegate: SBDrawerCenterDelegate?
    
    static var statusBarAnimationTime = 0.25
    
    override func panGestureCallback(panGesture: UIPanGestureRecognizer!) {
        
        switch panGesture.state {
            
        case .Changed,
             .Began:
            if visibleLeftDrawerWidth > 0 {
                centerDelegate?.isDrawerVisible = true
            }
        case .Failed,
             .Ended:
            if centerDelegate?.isDrawerVisible == true {
                centerDelegate?.drawerToggleAnimation()
            }
            
        default:
            break
        }
        super.panGestureCallback(panGesture)
    }
    
    private func updateCenterDelegate() {
        var sbController = self.centerViewController as? StudyBoxViewController
        if sbController == nil {
            if let navigationController = self.centerViewController as? UINavigationController where !navigationController.childViewControllers.isEmpty {
                
                sbController = navigationController.childViewControllers[0] as? StudyBoxViewController
            }
        }
        centerDelegate = sbController as? SBDrawerCenterDelegate

    }
    
    override func setCenterViewController(newCenterViewController: UIViewController!,
                                          withFullCloseAnimation fullCloseAnimated: Bool, completion: ((Bool) -> Void)!) {
        super.setCenterViewController(newCenterViewController, withFullCloseAnimation: fullCloseAnimated, completion: completion)
        updateCenterDelegate()
    }
    override func setCenterViewController(centerViewController: UIViewController!,
                                          withCloseAnimation closeAnimated: Bool, completion: ((Bool) -> Void)!) {
        super.setCenterViewController(centerViewController, withCloseAnimation: closeAnimated, completion: completion)
        updateCenterDelegate()
    }
    override var centerViewController: UIViewController! {
        didSet {
            updateCenterDelegate()
            
        }
    }
    
    override func closeDrawerAnimated(animated: Bool, velocity: CGFloat, animationOptions options: UIViewAnimationOptions,
                                      completion: ((Bool) -> Void)!) {
        var completionBlock = completion
        
        
            completionBlock = {[completion] (success: Bool) -> Void in
                if let sbController = self.centerDelegate as? StudyBoxViewController {
                    
                    sbController.isDrawerVisible = true
                    sbController.setNeedsStatusBarAppearanceUpdate()
                    
                    
                    sbController.drawerToggleAnimation()

                }
                
                completion?(success)
            }
            
        
        
        super.closeDrawerAnimated(animated, velocity: velocity, animationOptions: options, completion: completionBlock)
        
    }
    
    override func openDrawerSide(drawerSide: MMDrawerSide, animated: Bool, completion: ((Bool) -> Void)!) {
        centerDelegate?.drawerToggleAnimation()
        super.openDrawerSide(drawerSide, animated: animated, completion: completion)
    }
    
}
