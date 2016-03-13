//
//  UIAlertController+BasicAlert.swift
//  Plany Jup
//
//  Created by Damian Malarczyk on 07.02.2016.
//  Copyright © 2016 Damian. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    class func basicAlertCall(parent:UIViewController,title:String,message:String,buttonText:String,completition:(()->Void)? = nil ,dissmissCompletition:(()->Void)? = nil ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction( UIAlertAction(title: buttonText, style: .Default, handler: {[weak parent] (_) in
            completition?()
            if parent != nil {
                alert.dismissViewControllerAnimated(true) {
                    dissmissCompletition?()
                }
            }
        }))
        
        parent.presentViewController(alert, animated: true, completion: nil)
    }
}
