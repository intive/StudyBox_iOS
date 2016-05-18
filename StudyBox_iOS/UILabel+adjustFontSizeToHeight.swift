//
//  UILabel+.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 3.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
// this extension dynamically change the size of the fonts, so text can fit
extension UILabel {
    func adjustFontSizeToHeight(font: UIFont, max: CGFloat, min: CGFloat)
    {
        var font = font
        // Initial size is max and the condition the min.
        for size in max.stride(through: min, by: -0.1) {
            font = font.fontWithSize(size)
            if let text = self.text{
                let attrString = NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
                let rectSize = attrString.boundingRectWithSize(CGSize(width: self.bounds.width, height: CGFloat.max),
                                                               options: .UsesLineFragmentOrigin, context: nil)
                
                if rectSize.size.height <= self.bounds.height
                {
                    self.font = font
                    break
                }
            }
        }
        // in case, it is better to have the smallest possible font
        self.font = font
    }
}
