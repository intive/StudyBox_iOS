//
//  Colors.swift
//  StudyBox_iOS
//
//  Created by Daniel Sadka on 07/03/16.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension UIColor{
    class func sb_DarkBlue() -> UIColor{
        return UIColor(red: 0, green: (104 / 255.0), blue: (180 / 255.0), alpha: 1)
    }
    class func sb_Raspberry() -> UIColor{
        return UIColor(red: (234 / 255.0), green: 0, blue: (97 / 255.0), alpha: 1)
    }
    class func sb_Graphite() -> UIColor{
        return UIColor(red: (66 / 255.0), green: (66 / 255.0), blue: (66 / 255.0), alpha: 1)
    }
    class func sb_Grey() -> UIColor{
        return UIColor(red: (250 / 255.0), green: (250 / 255.0), blue: (250 / 255.0), alpha: 1)
    }
    
    class func defaultNavBarColor() -> UIColor {
        return UIColor(red:245.0/255, green:245.0/255, blue:246.0/255, alpha:1)
    }
    
    class func sb_DarkGrey() -> UIColor {
        return UIColor.grayColor()
    }
}
