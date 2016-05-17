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
    func updateStatusBar()
}

class SBDrawerController: MMDrawerController {
    
    var centerDelegate: SBDrawerCenterDelegate?
        
    override var centerViewController: UIViewController! {
        didSet {
            updateCenterDelegate()
            
        }
    }

    var  drawerAnimationTime: NSTimeInterval {
        var newFrame: CGRect
        let oldFrame = self.centerViewController.view.frame
        newFrame = self.centerViewController.view.frame
        newFrame.origin.x = self.maximumLeftDrawerWidth
        
        let distance = abs(oldFrame.minX - newFrame.origin.x)
        return max(Double(distance/abs(animationVelocity)), 0.1)
    }
    
    var defaultNavBarColor = UIColor.defaultNavBarColor()
    var graphiteColor = UIColor.sb_Graphite()
    
    override func panGestureCallback(panGesture: UIPanGestureRecognizer!) {
        prePanGestureCallback(panGesture)

        let animationTime = drawerAnimationTime
        super.panGestureCallback(panGesture)

        postPanGestureCallback(panGesture, animationTime: animationTime)
        if panGesture.state == .Recognized {
            hideKeyboard()
        }
    }
    
    func hideKeyboard() {
        UIApplication.sharedApplication().sendAction(#selector(resignFirstResponder), to: nil, from: nil, forEvent: nil)
    }

    private func prePanGestureCallback(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .Began:
            if let drawer = leftDrawerViewController as? DrawerViewController where drawer.barStyle == .LightContent {
                drawer.barStyle = .Default
            }
        case .Changed:
            if visibleLeftDrawerWidth > 0 {
                self.statusBarViewBackgroundColor = UIColor.fade(fromColor: defaultNavBarColor, toColor: graphiteColor,
                                                                 currentStep: visibleLeftDrawerWidth, steps: maximumLeftDrawerWidth)
            }
        case .Failed,
             .Ended:
            if visibleLeftDrawerWidth.isZero {
                self.statusBarViewBackgroundColor = defaultNavBarColor
                if let delegate = centerDelegate where delegate.isDrawerVisible {
                    centerDelegate?.drawerToggleAnimation()
                }
            }
        default:
            break
        }
    }

    private func postPanGestureCallback(panGesture: UIPanGestureRecognizer, animationTime: NSTimeInterval) {
        switch panGesture.state {
        case .Failed,
             .Ended:
            if let drawer = leftDrawerViewController as? DrawerViewController {
                UIView.animateWithDuration(animationTime, animations: {
                    if self.visibleLeftDrawerWidth != 0 {
                        drawer.barStyle = .LightContent

                    } else {
                        drawer.barStyle = .Default
                    }
                    drawer.setNeedsStatusBarAppearanceUpdate()
                })
            }
        default:
            break
        }
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
    
    override func setCenterViewController(newCenterViewController: UIViewController!, withFullCloseAnimation fullCloseAnimated: Bool,
                                          completion: ((Bool) -> Void)!) { // swiftlint:disable:this force_unwrapping
        super.setCenterViewController(newCenterViewController, withFullCloseAnimation: fullCloseAnimated, completion: completion)
        updateCenterDelegate()
    }
    override func setCenterViewController(centerViewController: UIViewController!, withCloseAnimation closeAnimated: Bool,
                                          completion: ((Bool) -> Void)!) { // swiftlint:disable:this force_unwrapping
        super.setCenterViewController(centerViewController, withCloseAnimation: closeAnimated, completion: completion)
        updateCenterDelegate()
    }
    
    override func closeDrawerAnimated(animated: Bool, velocity: CGFloat, animationOptions options: UIViewAnimationOptions,
                                      completion: ((Bool) -> Void)!) { // swiftlint:disable:this force_unwrapping
        var completionBlock = completion
        
        UIView.animateWithDuration(drawerAnimationTime,
            animations: {
                self.statusBarViewBackgroundColor = UIColor.defaultNavBarColor()
            })
        
        completionBlock = {[weak self] (success: Bool) -> Void in
            if let sbController = self?.centerDelegate as? StudyBoxViewController {
                sbController.isDrawerVisible = false
                sbController.updateStatusBar()
            }
            completion?(success)
        }
        
        super.closeDrawerAnimated(animated, velocity: velocity, animationOptions: options, completion: completionBlock)
        
    }
    
    override func openDrawerSide(drawerSide: MMDrawerSide, animated: Bool,
                                 velocity: CGFloat,
                                 animationOptions options: UIViewAnimationOptions,
                                 completion: ((Bool) -> Void)!) { // swiftlint:disable:this force_unwrapping
        hideKeyboard()
        self.centerDelegate?.drawerToggleAnimation()

        super.openDrawerSide(drawerSide, animated: animated, velocity: velocity, animationOptions: options, completion: completion)
        
        UIView.animateWithDuration(drawerAnimationTime,
            animations: {
                if let drawer = self.leftDrawerViewController as? DrawerViewController {
                    drawer.barStyle = .LightContent
                    drawer.setNeedsStatusBarAppearanceUpdate()
                    
                }
                self.statusBarViewBackgroundColor = UIColor.sb_Graphite()
            })
    }
    
    
}
