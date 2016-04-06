//
//  Fonts.swift
//  StudyBox_iOS
//
//  Created by Piotr Burzyński on 04.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

internal let sbFontSizeSmall: CGFloat = 10
internal let sbFontSizeMedium: CGFloat = 15
internal let sbFontSizeLarge: CGFloat = 20
internal let sbFontSizeSuperLarge: CGFloat = 28

extension UIFont{
  class func sbFont(size size: CGFloat = sbFontSizeMedium, bold: Bool) -> UIFont {
    
    if !bold {
      return UIFont(name: "Lato-Regular", size: size)!
    } else {
      return UIFont(name: "Lato-Black", size: size)!
    }
    
  }
}
