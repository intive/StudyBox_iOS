//
//  Fonts.swift
//  StudyBox_iOS
//
//  Created by Piotr Burzyński on 04.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension UIFont{
    class func studyBoxRegular(size: CGFloat = 13)->UIFont {
            return UIFont(name: "Lato-Regular", size: size)!
    }
    class func studyBoxBlack(size: CGFloat = 13)->UIFont {
        return UIFont(name: "Lato-Black", size: size)!
    }
}
