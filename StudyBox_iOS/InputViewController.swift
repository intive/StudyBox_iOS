//
//  InputViewController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 27.02.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

protocol InputViewControllerDataSource {
    var inputViews: [UITextField] { get set }
}


/**
Basic input view controller, which can dismiss keyboard by a down swipe gesture and adjust view origin for given `UITextField` inputs 
 - precondition: dataSource:`InputViewControllerDataSource` must not be nil before entering `viewDidAppear` method
 - important: on method `viewWillDisappear:`, `dataSource` will be set to nil, otherwise there would be a risk of reference cycle
*/
class InputViewController: UIViewController, UITextFieldDelegate  {

   //Data source gives information about each `UITextField` of the subclass
    var dataSource: InputViewControllerDataSource?
    
    //Current edit field input, so the view origin can be adjusted
    private var currentLowestInputView: UIView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(InputViewController.hideKeyboard))
        swipeGestureRecognizer.direction = .Down
        view.addGestureRecognizer(swipeGestureRecognizer)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dataSourcePrecondition()
        if let dataSource = dataSource {
            dataSource.inputViews.forEach {
                $0.delegate = self
            }
        }
       
        let defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.addObserver(self, selector: #selector(InputViewController.keyboardChangedFrame(_:)), name: UIKeyboardWillShowNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(InputViewController.keyboardChangedFrame(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dataSource = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        currentLowestInputView = textField
        return true
    }
    
    private func dataSourcePrecondition(){
        assert(dataSource != nil, "No data source for InputViewController")
    }
    
    
     // With keyboard apperance if `currentLowestInputView` would be covered by keyboard, view's vertical origin will be rised
     // With keyboard disappearance vertical origin is set to it's initial position
    func keyboardChangedFrame(notification: NSNotification) {
        dataSourcePrecondition()
        if let rect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(), lowestView = currentLowestInputView {
            
            switch notification.name {
                
            case UIKeyboardWillShowNotification:
                var originChange: CGFloat = 0
                let yOffset = lowestView.convertRect(lowestView.frame, fromView: view).origin.y
                let lowestBeginOriginY = lowestView.frame.height + lowestView.frame.origin.y - yOffset
                
                if rect.origin.y <= lowestBeginOriginY {
                    originChange = CGFloat((lowestBeginOriginY - rect.origin.y + 8) )
                }
                self.view.bounds.origin.y = originChange
                
            case UIKeyboardWillHideNotification:
                self.view.bounds.origin.y = 0
                
            default: break
            }
        }
    }
    
    func hideKeyboard(){
        dataSourcePrecondition()
        if let dataSource = dataSource{
            dataSource.inputViews.forEach {
                $0.resignFirstResponder()
            }
        }
    }
}
