//
//  Fonts.swift
//  StudyBox_iOS
//
//  Created by Piotr Burzyński on 04.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

internal let SBFontSizeSmall:CGFloat = 10
internal let SBFontSizeMedium:CGFloat = 15
internal let SBFontSizeLarge:CGFloat = 20

extension UIFont{
  class func studyBoxFont(size size: CGFloat = 13, bold:Bool)->UIFont {
    
    if !bold {
      return UIFont(name: "Lato-Regular", size: size)!
    } else {
      return UIFont(name: "Lato-Black", size: size)!
    }
    
  }
}
