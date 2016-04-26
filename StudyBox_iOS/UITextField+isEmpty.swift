//
//  UITextField+isEmpty.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 04.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension UITextField {
    func isEmpty() -> Bool  {
        if let text = text {
            if text.isEmpty {
                return true
            }
            return false
        }
        return true
    }
}
