//
//  UIViewController+showAlertController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 16.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentAlertController(withTitle title: String, message: String, buttonText: String, actionCompletion: (() -> Void)? = nil,
                                          dismissCompletion:(() -> Void)? = nil ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction( UIAlertAction(title: buttonText, style: .Default) { (_) in
            actionCompletion?()
            
            self.dismissViewControllerAnimated(true) {
                dismissCompletion?()
            }
        })
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
