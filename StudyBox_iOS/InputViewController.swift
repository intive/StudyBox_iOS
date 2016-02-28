//
//  InputViewController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 27.02.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

protocol InputViewControllerDataSource {
    var inputViews:[UITextField] { get set }
}


/**
Basic input view controller, which can dismiss keyboard by a down swipe gesture and adjust view origin for given `UITextField` inputs 
 - precondition: dataSource:`InputViewControllerDataSource` must not be nil
 - important: on method `viewWillDisappear:`, `dataSource` will be set to nil, otherwise there would be a risk of reference cycle
*/
class InputViewController: UIViewController,UITextFieldDelegate  {

   /**
     Data source gives information about each `UITextField` of the subclass
     
    */
    var dataSource:InputViewControllerDataSource?
    
    /**
     Current edit field input, so the view origin can be adjusted
     */
    private var currentLowestInputView:UIView? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("hideKeyboard"))
        swipeGestureRecognizer.direction = .Down
        view.addGestureRecognizer(swipeGestureRecognizer)
    
        let defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.addObserver(self, selector: Selector("keyboardChangedFrame:"), name: UIKeyboardWillShowNotification, object: nil)
        defaultCenter.addObserver(self, selector: Selector("keyboardChangedFrame:"), name: UIKeyboardWillHideNotification, object: nil)
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSourcePrecondition()
        dataSource!.inputViews.forEach {
            $0.delegate = self
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        dataSource = nil 
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        currentLowestInputView = textField
        return true
    }
    
    private func dataSourcePrecondition(){
        assert(dataSource != nil,"No data source for InputViewController")
    }
    
    
    /**
     With keyboard apperance if `currentLowestInputView` would be covered by keyboard, view's vertical origin will be rised
     
     With keyboard disappearance vertical origin is set to it's initial position
    */
    func keyboardChangedFrame(notification:NSNotification){
        dataSourcePrecondition()
        if let rect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(), let lowestView = currentLowestInputView {
            
            switch notification.name {
                
            case UIKeyboardWillShowNotification:
                
                var originChange:CGFloat?
                let lowestBeginOriginY = lowestView.frame.height + lowestView.frame.origin.y
                
                if rect.origin.y <= lowestBeginOriginY {
                    originChange = CGFloat((lowestBeginOriginY - rect.origin.y + 8) )
                }
    
                if let change = originChange {
                    self.view.bounds.origin.y = change
                }
                
            case UIKeyboardWillHideNotification:
                self.view.bounds.origin.y = 0
                
            default: break
            }
        }
    }
    
    func hideKeyboard(){
        dataSourcePrecondition()
        dataSource!.inputViews.forEach {
            $0.resignFirstResponder()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
